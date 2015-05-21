//
//  Trail.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import MapKit

class Trail: Printable
{
	var name: String?
	var date: NSDate?
	var link: NSURL?
	var length: Double?
	var ascent: Double?
	var difficulty: [Int]?
	var strenuousness: Double?
	var duration: String?
	var water: String?
	var food: String?
	var terrains: [String:Double]?
	var traces: [NSURL]?
	
	var gpxOverlays: [MKOverlay]?
	var overlaysShown = false
	
	var description: String
	{
		return "Name: \(name)\n Date: \(date)\n Link: \(link)\n Length: \(length)\n Ascent: \(ascent)\n Difficulty: \(difficulty)\n Strenuousness: \(strenuousness)\n Duration: \(duration)\n Water: \(water)\n Food: \(food)\n Terrains: \(terrains)\n Traces: \(traces)\n"
	}
}