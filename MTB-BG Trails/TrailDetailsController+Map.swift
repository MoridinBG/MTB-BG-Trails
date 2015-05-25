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
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!
    {
        if let polyline = overlay as? MKAttribuedPolyline
        {
            if polyline.attributes.optional && !isRenderingOptionals
            {
                return nil
            }
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            let r = CGFloat(arc4random_uniform(256))
            let g = CGFloat(arc4random_uniform(256))
            let b = CGFloat(arc4random_uniform(256))
            let alpha: CGFloat
            if polyline.attributes.optional
            {
                alpha = 0.3
            } else
            {
                alpha = 0.7
            }
            let color = UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
            
            polylineRenderer.strokeColor = color
            polylineRenderer.lineWidth = 3
            
            return polylineRenderer
        } else
        {
            return nil
        }
    }
    
    func fitTrailsInMapRegion(region: MKCoordinateRegion)
    {
        let mapViewRegion = mapView.regionThatFits(region)
        mapView.setRegion(mapViewRegion, animated: true)
    }
    
    func fitTrailInMap(trail: Trail)
    {
        var upper = CLLocationCoordinate2DMake(-91.0, -181.0)
        var lower = CLLocationCoordinate2DMake(91.0, 181.0)
        
        for track in trail.gpsTracks()
        {
            var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(track.trackPolyline.pointCount)
            track.trackPolyline.getCoordinates(coordsPointer, range: NSMakeRange(0, track.trackPolyline.pointCount))
            
            var coords: [CLLocationCoordinate2D] = []
            for i in 0..<track.trackPolyline.pointCount
            {
                coords.append(coordsPointer[i])
            }
            
            coordsPointer.dealloc(track.trackPolyline.pointCount)
            
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
        let trailsSpan = MKCoordinateSpanMake((upper.latitude - lower.latitude) * 1.1,
            (upper.longitude - lower.longitude) * 1.1)
        let trailsCenter = CLLocationCoordinate2DMake((upper.latitude + lower.latitude) / 2,
            (upper.longitude + lower.longitude) / 2)
        var region = MKCoordinateRegionMake(trailsCenter, trailsSpan)
        
        let mapViewRegion = mapView.regionThatFits(region)
        mapView.setRegion(mapViewRegion, animated: true)
    }
}