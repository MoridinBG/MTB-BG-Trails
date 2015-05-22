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
		if let polyline = overlay as? MKColoredPolyline
        {            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = polyline.colour
            polylineRenderer.lineWidth = 3
		
            return polylineRenderer
        } else
        {
            return nil
        }
	}
	
	func fitTrailsInMap()
	{
		if let region = trailsLoader.region
		{
			let mapViewRegion = mapView.regionThatFits(region)
			mapView.setRegion(mapViewRegion, animated: true)
		}
	}
    
    func fitTrailInMap(trail: Trail)
    {
        var upper = CLLocationCoordinate2DMake(-91.0, -181.0)
        var lower = CLLocationCoordinate2DMake(91.0, 181.0)
        
        for overlay in trail.gpxOverlays!
        {
            if let polyline = overlay as? MKPolyline
            {
                var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(polyline.pointCount)
                polyline.getCoordinates(coordsPointer, range: NSMakeRange(0, polyline.pointCount))
                
                var coords: [CLLocationCoordinate2D] = []
                for i in 0..<polyline.pointCount
                {
                    coords.append(coordsPointer[i])
                }

                coordsPointer.dealloc(polyline.pointCount)
                
                for point in coords
                {
                    if point.latitude > upper.latitude
                    {
                        upper.latitude = point.latitude
                    }
                    if point.latitude < lower.latitude
                    {
                        lower.latitude = point.latitude
                    }
                    
                    if point.longitude > upper.longitude
                    {
                        upper.longitude = point.longitude
                    }
                    if point.longitude < lower.longitude
                    {
                        lower.longitude = point.longitude
                    }
                }
                

            }
        }
        let trailsSpan = MKCoordinateSpanMake((upper.latitude - lower.latitude) * 1.1,
            (upper.longitude - lower.longitude) * 1.1)
        let trailsCenter = CLLocationCoordinate2DMake((upper.latitude + lower.latitude) / 2,
            (upper.longitude + lower.longitude) / 2)
        var region = MKCoordinateRegionMake(trailsCenter, trailsSpan)
        
        let mapViewRegion = mapView.regionThatFits(region)
        mapView.setRegion(mapViewRegion, animated: true)
    }
}