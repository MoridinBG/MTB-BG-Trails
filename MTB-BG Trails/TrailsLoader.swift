//
//  TrailsLoader.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/15/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import SwiftyJSON

class TrailsLoader
{
	var trails = [Trail]()
	
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
	
	func loadTrails(url: NSURL, onLoadFinished: (([Trail]) -> Void)?)
	{
		trails = [Trail]()
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

}