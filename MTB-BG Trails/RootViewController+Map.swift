//
//  RootViewController+Map.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/16/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import MapKit

extension RootViewController: MKMapViewDelegate
{
	func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!
	{
		if !(overlay is MKPolyline)
		{
			return nil
		}
		
		let polylineRenderer = MKPolylineRenderer(overlay: overlay)
		polylineRenderer.strokeColor = UIColor.blueColor()
		polylineRenderer.lineWidth = 3
		
		return polylineRenderer
	}
	
	func fitTrailsInMap()
	{
		if let region = trailsLoader.region
		{
			let mapViewRegion = mapView.regionThatFits(region)
			mapView.setRegion(mapViewRegion, animated: true)
		}
	}
}