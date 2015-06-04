//
//  TrailDetailsController+Map.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/24/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import MapKit

extension TrailDetailsController: MKMapViewDelegate
{
    override func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!
    {
        if let polyline = overlay as? MKAttribuedPolyline
        {
            if polyline.attributes.optional && !isRenderingOptionals
            {
                return nil
            }
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            if polyline.attributes.optional
            {
                let r = CGFloat(arc4random_uniform(256))
                let g = CGFloat(arc4random_uniform(256))
                let b = CGFloat(arc4random_uniform(256))
                let alpha = CGFloat(0.3)
                let color = UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
                polylineRenderer.strokeColor = color
            } else
            {
                polylineRenderer.strokeColor = polyline.attributes.colour
            }
            
            polylineRenderer.lineWidth = 3
            
            return polylineRenderer
        } else
        {
            return super.mapView(mapView, rendererForOverlay: overlay)
        }
    }
}