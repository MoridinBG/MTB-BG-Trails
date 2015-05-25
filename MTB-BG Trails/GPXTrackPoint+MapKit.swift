//
//  GPXPoint+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//


import Foundation
import UIKit
import MapKit


extension GPXTrackPoint {

    convenience init(location: CLLocation) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.time = NSDate();
        self.elevation = location.altitude
    }
    
    func coordinate() -> CLLocationCoordinate2D
    {
        return CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
}