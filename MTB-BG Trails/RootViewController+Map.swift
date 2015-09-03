//
//  RootViewController+Map.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/16/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import MapKit

//TODO: Make into superclass for RootView and TrailDetails controllers
extension RootViewController: MKMapViewDelegate
{
	override func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!
	{
		if let polyline = overlay as? MKAttribuedPolyline
        {            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = polyline.attributes.colour
            polylineRenderer.lineWidth = 3
		
            return polylineRenderer
        } else
        {
            return super.mapView(mapView, rendererForOverlay: overlay)
        }
	}
	
    func fitTrailsInMap(animated animated: Bool)
	{
		if let region = trailsLoader.mapRegion
		{
			let mapViewRegion = mapView.regionThatFits(region)
			mapView.setRegion(mapViewRegion, animated: animated)
		}
	}    
}