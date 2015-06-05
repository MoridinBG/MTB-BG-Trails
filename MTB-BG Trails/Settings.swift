//
//  Settings.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 6/4/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

struct Settings
{
    static func initializeSettings()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(Constants.Keys.kDefaultsMapStyle) == nil
        {
            defaults.setObject(Maps.MapStyle.OpenCycleMap.rawValue, forKey: Constants.Keys.kDefaultsMapStyle)
        }
        
        if defaults.objectForKey(Constants.Keys.kDefaultsMaxMapCache) == nil
        {
            defaults.setInteger(Constants.Values.vDefaultsMaxMapCache, forKey: Constants.Keys.kDefaultsMaxMapCache)
        }
        
    }
    
    static func clearSettings()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(Maps.MapStyle.OpenCycleMap.rawValue, forKey: Constants.Keys.kDefaultsMapStyle)
        defaults.setInteger(Constants.Values.vDefaultsMaxMapCache, forKey: Constants.Keys.kDefaultsMaxMapCache)
    }
    
    struct OfflineMaps
    {
        static var maps: [DownloadedMap]?
        {
            get
            {
                let codedMaps = NSUserDefaults.standardUserDefaults().objectForKey(Constants.Keys.kDefaultsOfflineMaps) as? [NSData]
                if let codedMaps = codedMaps
                {
                    var maps = [DownloadedMap]()
                    for data in codedMaps
                    {
                        maps.append(NSKeyedUnarchiver.unarchiveObjectWithData(data) as! DownloadedMap)
                    }
            
                    return maps
                } else
                {
                    return nil
                }
            }
            
            set
            {
                if let maps = newValue
                {
                    var codedMaps = [NSData]()
                    for map in newValue!
                    {
                        codedMaps.append(NSKeyedArchiver.archivedDataWithRootObject(map))
                    }
                    NSUserDefaults.standardUserDefaults().setObject(codedMaps, forKey: Constants.Keys.kDefaultsOfflineMaps)
                }
            }
        }
        
        static func addMap(map: DownloadedMap)
        {
            if OfflineMaps.maps == nil
            {
                OfflineMaps.maps = [DownloadedMap]()
            }
            
            var maps = OfflineMaps.maps!
            maps.append(map)
            OfflineMaps.maps = maps
        }
    }
    
    struct Maps
    {
        enum MapStyle: String
        {
            case OpenCycleMap          = "ocm"
            case OpenStreetMapStandard = "osm.standard"
            case OpenStreetMapOutdoors = "osm.outdoors"
            case OpenStreetMapLandscae = "osm.landscape"

            case AppleStandard         = "apple.standard"
            case AppleSatellite        = "apple.satellite"
            case AppleHybrid           = "apple.hybrid"
        }
        static var style: MapStyle
        {
            get
            {
                return MapStyle(rawValue: NSUserDefaults.standardUserDefaults().stringForKey(Constants.Keys.kDefaultsMapStyle)!)!
            }
            
            set
            {
                NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: Constants.Keys.kDefaultsMapStyle)
            }
        }
    }
    
    struct Cache
    {
        static var maxMapTileCache: Int
        {
            get
            {
                return NSUserDefaults.standardUserDefaults().integerForKey(Constants.Keys.kDefaultsMaxMapCache)
            }
            
            set
            {
                NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: Constants.Keys.kDefaultsMaxMapCache)
            }
        }
    }
    
}