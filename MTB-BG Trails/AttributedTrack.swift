//
//  MKColoredPolyline.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/22/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import MapKit

class AttributedTrack
{
    var pointElevations: [CLLocationDistance]
    var length: Double
    var colour: UIColor
    var name: String
    
    var optional = false
    
    var trackPolyline: MKAttribuedPolyline
    
    init(coords: UnsafeMutablePointer<CLLocationCoordinate2D>, count: Int, pointElevations: [CLLocationDistance] = [CLLocationDistance](), length: Double = 0.0, colour: UIColor = UIColor.whiteColor(), name: String = "", optional: Bool = false)
    {
        self.pointElevations = pointElevations
        self.length = length
        self.name = name
        self.colour = colour
        self.optional = optional
        self.trackPolyline = MKAttribuedPolyline(coordinates: coords, count: count)
        self.trackPolyline.attributes = self
    }
}