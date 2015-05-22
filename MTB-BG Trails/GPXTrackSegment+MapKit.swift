//
//  GPXTrackSegment+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//


import Foundation
import UIKit
import MapKit

//
//This extension adds some methods to work with mapkit
//
extension GPXTrackSegment
{
  
    // Returns a mapkit polyline with the points of the segment.
    // This polyline can be directly plotted on the map as an overlay
    var overlay: MKColoredPolyline
	{
        get
		{
            var coords = self.trackPointsToCoordinates()
            let polyline = MKColoredPolyline(coordinates: &coords, count:  coords.count)
			
            return polyline
		}
	}
    
    
    //Helper method to create the polyline. Returns the array of coordinates of the points
    //that belong to this segment
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D]
	{
        var coords = [CLLocationCoordinate2D]()
        
        for point in self.trackpoints
		{
            let pt = point as! GPXTrackPoint
            coords.append(CLLocationCoordinate2DMake(pt.latitude, pt.longitude))
        }
        return coords
    }
}