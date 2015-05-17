//
//  TrailsLoader.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/15/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import SwiftyJSON
import MapKit

protocol TrailsLoaderDelegate
{
	func allGPXLoaded()
}

class TrailsLoader
{
	var trails = [Trail]()
	
	var region: MKCoordinateRegion?
	var delegate: TrailsLoaderDelegate?
	
	private var gpxLoadedCount = 0
	private var upper = CLLocationCoordinate2DMake(-91.0, -181.0)
	private var lower = CLLocationCoordinate2DMake(91.0, 181.0)
	
	func loadTrails(url: NSURL, onLoadFinished: (([Trail]) -> Void)?)
	{
		trails = [Trail]()
		gpxLoadedCount = 0
		requestTrails(url, onComplete: { (data, error) in
			if let jsonData = data
			{
				let json = JSON(data: jsonData)
				
				for(index: String, subJson: JSON) in json["routes"]
				{
					var trail = Trail()
					trail.name = subJson["name"].string
					
					if let dateString = subJson["date"].string
					{
						let dateFormatter = NSDateFormatter()
						let locale = NSLocale(localeIdentifier: "bg_BG_POSIX")
						dateFormatter.locale = locale
						dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
						trail.date = dateFormatter.dateFromString(dateString)
					}
					
					if let linkString = subJson["link"].string
					{
						trail.link = NSURL(string: linkString)
					}
					
					trail.length = subJson["length"].double
					trail.ascent = subJson["ascent"].double
					trail.duration = subJson["duration"].string
					trail.water = subJson["water"].string
					trail.food = subJson["food"].string
					
					for(index: String, subTerrain: JSON) in subJson["terrains"]
					{
						if trail.terrains == nil
						{
							trail.terrains = [String: Double]()
						}
						
						if let terrain = subTerrain["terrain"].string, let length = subTerrain["length"].double
						{
							trail.terrains![terrain] = length
						}
					}
					
					for(index: String, subTrace: JSON) in subJson["traces"]
					{
						if trail.traces == nil
						{
							trail.traces = [NSURL]()
						}
						
						if let traceString = subTrace.string
						{
							trail.traces?.append(NSURL(string: traceString)!)
						}
					}
					
					if let traces = trail.traces
					{
						if traces.count > 0
						{
							let url = traces[0]
							self.requestGPXFile(url) { (root) in
								trail.gpxRoot = root
							}
						}
					}
					
					self.trails.append(trail)
					if let onLoadFinished = onLoadFinished
					{
						onLoadFinished(self.trails)
					}
				}
			} else
			{
				println("Error getting remote JSON data: \(error?.localizedDescription)")
			}
		})
	}
	
	private func requestTrails(url: NSURL, onComplete: (data: NSData?, error: NSError?) -> Void)
	{
		let session = NSURLSession.sharedSession()
		//Use NSURLSession to get data from an NSURL
		let loadDataTask = session.dataTaskWithURL(NSURL(string:Constants.Values.vJSONTrailsURL)!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
			
			if let responseError = error
			{
				onComplete(data: nil, error: responseError)
			} else if let httpResponse = response as? NSHTTPURLResponse
			{
				if httpResponse.statusCode != 200
				{
					var statusError = NSError(domain:"com.techlight", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "Unexpected HTTP status."])
					onComplete(data: nil, error: statusError)
				} else
				{
					onComplete(data: data, error: nil)
				}
			}
		})
		
		loadDataTask.resume()
	}
	
	private func requestGPXFile(url: NSURL, processFile: (gpxRoot: GPXRoot) -> Void)
	{
		self.gpxLoadedCount++
		let string = url.absoluteString!
		if string.rangeOfString(".zip", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil
		{
			return
		}
		
		let session = NSURLSession.sharedSession()
		//Use NSURLSession to get data from an NSURL
		let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
			
			if let responseError = error
			{
				println("Error loading GPX file: \(responseError.localizedDescription)")
			} else if let httpResponse = response as? NSHTTPURLResponse
			{
				if httpResponse.statusCode != 200
				{
					println("Bad HTTP status code when loading GPX: \(httpResponse.statusCode)")
				} else
				{
					let root = GPXParser.parseGPXWithData(data)
					
					for track in root.tracks as! [GPXTrack]
					{
						for segment in track.tracksegments as! [GPXTrackSegment]
						{
							for point in segment.trackpoints as! [GPXTrackPoint]
							{
								if point.latitude > self.upper.latitude
								{
									self.upper.latitude = point.latitude
								}
								if point.latitude < self.lower.latitude
								{
									self.lower.latitude = point.latitude
								}
								
								if point.longitude > self.upper.longitude
								{
									self.upper.longitude = point.longitude
								}
								if point.longitude < self.lower.longitude
								{
									self.lower.longitude = point.longitude
								}
							}
						}
					}
					
					let trailsSpan = MKCoordinateSpanMake((self.upper.latitude - self.lower.latitude) * 1.1,
															(self.upper.longitude - self.lower.longitude) * 1.1)
					let trailsCenter = CLLocationCoordinate2DMake((self.upper.latitude + self.lower.latitude) / 2,
																	(self.upper.longitude + self.lower.longitude) / 2)
					self.region = MKCoordinateRegionMake(trailsCenter, trailsSpan)
					
					if self.gpxLoadedCount == self.trails.count
					{
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							self.delegate?.allGPXLoaded()
						})
					}
					
					processFile(gpxRoot: root)
				}
			}
		})
		
		loadDataTask.resume()

	}

}