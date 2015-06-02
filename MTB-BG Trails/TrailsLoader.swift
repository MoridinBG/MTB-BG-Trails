//
//  TrailsLoader.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/15/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import MapKit

protocol TrailsLoaderDelegate
{
	func processedGPXIntoTracks(tracks: [AttributedTrack])
    func loadedTrail(trail: Trail)
}

struct Statistics
{
	var date = (min: NSDate(timeIntervalSinceNow: 0), max:NSDate(timeIntervalSince1970: 0))
	var length = (min: 1000.0, max: 0.0)
	var ascent = (min: 3000.0, max: -3000.0)
	var strenuousness = (min: 100.0, max: 0.0)
	var	difficulty = (min: 11, max: 0)
}

class TrailsLoader
{
    var delegate: TrailsLoaderDelegate?
    
	var _statistics = Statistics()
    var statistics: Statistics
    {
        get
        {
            var statisticsCopy: Statistics!
            dispatch_sync(concurrentStatisticsQueue) {
                statisticsCopy = self._statistics
            }
            return statisticsCopy
        }
        
        set
        {
            dispatch_barrier_async(concurrentStatisticsQueue) {
                self._statistics = newValue
            }
        }
    }
    
    var _mapRegion: MKCoordinateRegion?
    var mapRegion: MKCoordinateRegion?
    {
        var regionCopy: MKCoordinateRegion!
        dispatch_sync(concurrentRegionQueue) {
            regionCopy = self._mapRegion
        }
        
        return regionCopy
    }
	
	
    private let concurrentRegionQueue = dispatch_queue_create("com.techLight.mtb-bg.loaderAccessRegionQueue", DISPATCH_QUEUE_CONCURRENT)
    private let concurrentStatisticsQueue = dispatch_queue_create("com.techLight.mtb-bg.loaderAccessStatisticsQueue", DISPATCH_QUEUE_CONCURRENT)
    
    private var upper = CLLocationCoordinate2DMake(-91.0, -181.0)
	private var lower = CLLocationCoordinate2DMake(91.0, 181.0)
	
	//Loads the trails from JSON data
    func requestTrails(url: NSURL, sender: TrailsLoaderDelegate)
	{
		requestTrailsJSON(url, onComplete: { (data, error) in
			if let jsonData = data
			{
				let json = JSON(data: jsonData)
				let trailsCount = json["routes"].count
                let colours = DistinctColourGenerator.generateDistinctColours(trailsCount, quality: 1, highPrecision: false)
                
				for(index: String, trailJson: JSON) in json["routes"]
				{
                    self.processTrailFromJSON(trailJson, index: index, colorForTrail: colours[index.toInt()!])
                    if index == "10"
                    {
                        break
                    }
				}
				
			} else
			{
				println("Error getting remote JSON data: \(error?.localizedDescription)")
			}
		})
	}
	
    private func processTrailFromJSON(trailJson: JSON, index: String, colorForTrail: UIColor)
    {
        dispatch_async(GlobalBackgroundQueue)
        {
            var trail = Trail()
            trail.name = trailJson["name"].string
            trail.colour = colorForTrail
            
            if let dateString = trailJson["date"].string
            {
                let dateFormatter = NSDateFormatter()
                let locale = NSLocale(localeIdentifier: "bg_BG_POSIX")
                dateFormatter.locale = locale
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
                trail.date = dateFormatter.dateFromString(dateString)
                
                if let date = trail.date
                {
                    if date < self.statistics.date.min
                    {
                        self.statistics.date.min = date
                    }
                    
                    if date > self.statistics.date.max
                    {
                        self.statistics.date.max = date
                    }
                }
            }
            
            if let linkString = trailJson["link"].string
            {
                trail.link = NSURL(string: linkString)
                
            }
            
            if let length = trailJson["length"].double
            {
                trail.length = length
                
                if length < self.statistics.length.min
                {
                    self.statistics.length.min = length
                }
                
                if length > self.statistics.length.max
                {
                    self.statistics.length.max = length
                }
            }
            
            if var ascent = trailJson["ascent"].double
            {
                if ascent < 0
                {
                    ascent = 0
                }
                
                trail.ascent = ascent
                
                if ascent < self.statistics.ascent.min
                {
                    self.statistics.ascent.min = ascent
                }
                
                if ascent > self.statistics.ascent.max
                {
                    self.statistics.ascent.max = ascent
                }
            }
            
            for(index: String, diff: JSON) in trailJson["difficulty"]
            {
                if trail.difficulty == nil
                {
                    trail.difficulty = [Int]()
                }
                
                if let difficulty = diff.string
                {
                    if let diffIndex = Constants.Values.vTrailDifficultyClasses.find({ item in
                        return item == difficulty})
                    {
                        trail.difficulty!.append(diffIndex)
                        
                        if diffIndex < self.statistics.difficulty.min
                        {
                            self.statistics.difficulty.min = diffIndex
                        }
                        
                        if diffIndex > self.statistics.difficulty.max
                        {
                            self.statistics.difficulty.max = diffIndex
                        }
                    }
                }
            }
            
            if let stren = trailJson["strenuousness"].double
            {
                trail.strenuousness = stren
                if stren < self.statistics.strenuousness.min
                {
                    self.statistics.strenuousness.min = stren
                }
                
                if stren > self.statistics.strenuousness.max
                {
                    self.statistics.strenuousness.max = stren
                }
                
            } else
            {
                if let ascent = trail.ascent, length = trail.length
                {
                    var stren = length / 10 + (ascent / (length * 1000)) * 100.0
                    
                    if stren < 0
                    {
                        stren = 0
                    }
                    
                    if stren - Double(Int(stren)) >= 0.5
                    {
                        stren = ceil(stren)
                    } else
                    {
                        stren = floor(stren)
                    }
                    
                    trail.strenuousness = stren
                    
                    if stren < self.statistics.strenuousness.min
                    {
                        self.statistics.strenuousness.min = stren
                    }
                    
                    if stren > self.statistics.strenuousness.max
                    {
                        self.statistics.strenuousness.max = stren
                    }
                }
            }
            
            trail.duration = trailJson["duration"].string
            trail.water = trailJson["water"].string
            trail.food = trailJson["food"].string
            
            for(index: String, subTerrain: JSON) in trailJson["terrains"]
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
            
            for(index: String, subTrace: JSON) in trailJson["traces"]
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
                self.loadGPXFromTrail(trail) { gpx in
                    var tempTracks = [AttributedTrack]()
                    var longestIndex = -1
                    
                    for track in gpx.tracks as! [GPXTrack]
                    {
                        var (coordinates, elevations, length) = ([CLLocationCoordinate2D](), [CLLocationDistance](), 0.0)
                        for segment in track.tracksegments as! [GPXTrackSegment]
                        {
                            var segmentPoints = segment.points
                            coordinates += segmentPoints.0
                            elevations += segmentPoints.1
                            length += segmentPoints.2
                            
                        }
                        let attribTrack = AttributedTrack(coords: &coordinates, count: coordinates.count, pointElevations: elevations, length: length, colour: trail.colour, name: track.name, optional: true)
                        
                        if longestIndex >= 0
                        {
                            if length > tempTracks[longestIndex].length
                            {
                                longestIndex = tempTracks.count //This track is not added to the array yet! Will be added right after the outer If, so don't use count - 1
                            }
                        } else
                        {
                            longestIndex = 0
                        }
                        tempTracks.append(attribTrack)
                    }
                    
                    if longestIndex >= 0
                    {
                        trail.mainTrack = tempTracks[longestIndex]
                        trail.mainTrack!.optional = false
                        tempTracks.removeAtIndex(longestIndex)
                    }
                    
                    if tempTracks.count > 0
                    {
                        trail.optionalTracks = tempTracks
                    }
                    
                    trail.overlaysShown = true
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.processedGPXIntoTracks([trail.mainTrack!] + trail.optionalTracks)
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.loadedTrail(trail)
            }
        }
    }
    
	private func loadGPXFromTrail(theTrail: Trail, onLoadFinished: (gpx: GPXRoot) -> Void)
	{
		if let traces = theTrail.traces
		{
			if traces.count > 0
			{
				let url = traces[0]
				let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
				var filename = url.lastPathComponent!
				
				if filename.rangeOfString(".zip") != nil
				{
					filename = filename.stringByReplacingOccurrencesOfString(".zip", withString: ".gpx", options: .CaseInsensitiveSearch, range: nil)
				}
				
				if filename == "gpstrack0025_tracks.gpx"
				{
					filename = "gpstrack0025_Kremikovci-Yablanica.gpx"
				} else if filename == "gpstrack0027.gpx"
				{
					filename = "gpstrack0027_Bakiovo-Yablanica.gpx"
				} else if filename == "gpstrack0023_Zeleni-rid.gpx"
				{
					filename = "gpstrack0023_Zeleni-Rid.gpx"
				} else if filename == "gpstrack0028_lakatishka_Rila.gpx"
				{
					filename = "gpstrack0028_Lakatishka_Rila.gpx"
				} else if filename == "gpstrack0042_batak-peshtera.gpx"
				{
					filename = "gpstrack042_batak-peshtera.gpx"
				}
				
				filename = documentsPath.stringByAppendingPathComponent(filename)
				if NSFileManager.defaultManager().fileExistsAtPath(filename)
				{
					let root = GPXParser.parseGPXAtPath(filename)
					updateMapRegionWithTrack(root)
					onLoadFinished(gpx: root)
				} else
				{
					self.requestGPXFile(url) { (root) in
						self.updateMapRegionWithTrack(root)
						onLoadFinished(gpx: root)
					}
				}
			}
		}
	}
	
	private func requestTrailsJSON(url: NSURL, onComplete: (data: NSData?, error: NSError?) -> Void)
	{
		let reachability = Reachability.reachabilityForInternetConnection()
		
		
		let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String

		let tracksFile = documentsPath.stringByAppendingPathComponent(Constants.Values.vJSONTrailsFilename)
		
		if true//!reachability.isReachable()
		{
			var error: NSError? = nil
			let documentsFiles = NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsPath, error: &error)
			
			for file in documentsFiles as! [String]
			{
				if file == "trails.json"
				{
					let data = NSData(contentsOfFile: tracksFile)
					onComplete(data: data, error: nil)
					
					return
				}
			}
		}
		
		let session = NSURLSession.sharedSession()
		//Use NSURLSession to get data from an NSURL
		let loadDataTask = session.dataTaskWithURL(NSURL(string:Constants.Values.vJSONTrailsURL)!) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
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
					data.writeToFile(tracksFile, atomically: false)
					onComplete(data: data, error: nil)
				}
			}
		}
		
		loadDataTask.resume()
	}
	
	private func requestGPXFile(url: NSURL, processFile: (gpxRoot: GPXRoot) -> Void)
	{
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
					let root: GPXRoot
					let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
					var file = documentsPath.stringByAppendingPathComponent(url.lastPathComponent!)
					
					if url.absoluteString?.rangeOfString(".zip", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil
					{
						data.writeToFile(file, atomically: false)
						SSZipArchive.unzipFileAtPath(file, toDestination: documentsPath)
						
						var filename = url.lastPathComponent!
						if filename.rangeOfString(".zip") != nil
						{
							filename = filename.stringByReplacingOccurrencesOfString(".zip", withString: ".gpx", options: .CaseInsensitiveSearch, range: nil)
						}
						
						if filename == "gpstrack0025_tracks.gpx"
						{
							filename = "gpstrack0025_Kremikovci-Yablanica.gpx"
						} else if filename == "gpstrack0027.gpx"
						{
							filename = "gpstrack0027_Bakiovo-Yablanica.gpx"
						} else if filename == "gpstrack0023_Zeleni-rid.gpx"
						{
							filename = "gpstrack0023_Zeleni-Rid.gpx"
						} else if filename == "gpstrack0028_lakatishka_Rila.gpx"
						{
							filename = "gpstrack0028_Lakatishka_Rila.gpx"
						} else if filename == "gpstrack0042_batak-peshtera.gpx"
						{
							filename = "gpstrack042_batak-peshtera.gpx"
						}
						
						filename = documentsPath.stringByAppendingPathComponent(filename)
						root = GPXParser.parseGPXAtPath(filename)
						
						filename = filename.stringByReplacingOccurrencesOfString(".gpx", withString: ".gdb")
						if NSFileManager.defaultManager().fileExistsAtPath(filename)
						{
							NSFileManager.defaultManager().removeItemAtPath(filename, error: nil)
						}
						NSFileManager.defaultManager().removeItemAtPath(file, error: nil)
						
					} else
					{
						data.writeToFile(file, atomically: false)
						root = GPXParser.parseGPXWithData(data)
					}
					processFile(gpxRoot: root)
				}
			}
		})
		loadDataTask.resume()
	}
	
	private func updateMapRegionWithTrack(gpx: GPXRoot)
	{
        dispatch_barrier_async(concurrentRegionQueue) {
            for track in gpx.tracks as! [GPXTrack]
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
            self._mapRegion = MKCoordinateRegionMake(trailsCenter, trailsSpan)
        }
	}
}