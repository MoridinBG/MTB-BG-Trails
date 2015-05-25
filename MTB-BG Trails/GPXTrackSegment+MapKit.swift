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
    var points: ([CLLocationCoordinate2D], [CLLocationDistance], Double)
	{
        get
		{
            var coords = [CLLocationCoordinate2D]()
            var elevations = [CLLocationDistance]()
            var distance = 0.0
            
            var prevPoint: GPXTrackPoint?
            for point in self.trackpoints
            {
                let pt = point as! GPXTrackPoint
                if let prev = prevPoint
                {
                    distance += metersBetweenCoordinates(prev.coordinate(), coord2: pt.coordinate())
                }
                
                prevPoint = pt
                
                coords.append(CLLocationCoordinate2DMake(pt.latitude, pt.longitude))
                if let elevation = point.elevation
                {
                    elevations.append(elevation)
                } else if let elevation = point.geoidHeight
                {
                    elevations.append(elevation)
                } else
                {
                    println("No valid elevation data")
                }
                
            }
            
            return (coords, elevations, distance)
		}
	}
    
    func metersBetweenCoordinates(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> Double
    {
        let earthRadius = 6371.0 // km
        let deg2rad = M_PI / 180.0
        let dLat = (coord2.latitude - coord1.latitude) * deg2rad
        let dLon = (coord2.longitude - coord1.longitude) * deg2rad
        let lat1 = coord1.latitude * deg2rad
        let lat2 = coord2.latitude * deg2rad
        
        let a = sin(dLat / 2) * sin(dLat / 2) + sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = earthRadius * c;
        
        return distance
    }
}