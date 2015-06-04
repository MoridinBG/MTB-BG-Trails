//
//  MapViewCommon.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/26/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import MapKit

class MapViewCommon: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    var tileOverlay: MKTileOverlay?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let mapStyle = defaults.objectForKey(Constants.Keys.kDefaultsMapStyle) as! String
        let template: String
        
        switch mapStyle
        {
            case Constants.Values.vDefaultsMapStyleOCM:
                template = Constants.Values.vMapTilesOCM
                
            case Constants.Values.vDefaultsMapStyleOSMStd:
                template = Constants.Values.vMapTilesOSM
                
            case Constants.Values.vDefaultsMapStyleOSMOut:
                template = Constants.Values.vMapTilesOSMOut

            case Constants.Values.vDefaultsMapStyleOSMLand:
                template = Constants.Values.vMapTilesOSMLand
                
            
            
            case Constants.Values.vDefaultsMapStyleAppleStd:
                template = Constants.Values.vDefaultsMapStyleAppleStd
                
            case Constants.Values.vDefaultsMapStyleAppleSat:
                template = Constants.Values.vDefaultsMapStyleAppleSat
                
            case Constants.Values.vDefaultsMapStyleAppleHyb:
                template = Constants.Values.vDefaultsMapStyleAppleHyb
            
            default:
                println("Weird value for Map Style in Settings")
                template = Constants.Values.vDefaultsMapStyleOCM
        }
        
        switch template
        {
            case Constants.Values.vDefaultsMapStyleAppleStd:
                mapView.mapType = .Standard
                if let tileOverlay = tileOverlay
                {
                    self.mapView.removeOverlay(tileOverlay)
                }
            
            case Constants.Values.vDefaultsMapStyleAppleSat:
                mapView.mapType = .Satellite
                if let tileOverlay = tileOverlay
                {
                    self.mapView.removeOverlay(tileOverlay)
                }
            
            case Constants.Values.vDefaultsMapStyleAppleHyb:
                mapView.mapType = .Hybrid
                if let tileOverlay = tileOverlay
                {
                    self.mapView.removeOverlay(tileOverlay)
                }
            
            default:
                if let tileOverlay = tileOverlay
                {
                    self.mapView.removeOverlay(tileOverlay)
                }
                
                let overlays = mapView.overlays
                mapView.removeOverlays(overlays)
                
                tileOverlay = CachingTileOverlay(URLTemplate: template)
                tileOverlay!.canReplaceMapContent = true
                self.mapView.addOverlay(tileOverlay!)
            
                self.mapView.addOverlays(overlays)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!
    {
        if let overlay = overlay as? MKTileOverlay
        {
            return MKTileOverlayRenderer(tileOverlay: overlay)
        } else
        {
            return nil
        }
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