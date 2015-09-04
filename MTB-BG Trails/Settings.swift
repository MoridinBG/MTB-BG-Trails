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
        
        if defaults.objectForKey(Constants.Keys.kDefaultsOfflineMaps) == nil
        {
            defaults.setObject([NSData](), forKey: Constants.Keys.kDefaultsOfflineMaps)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    static func clearSettings()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(Maps.MapStyle.OpenCycleMap.rawValue, forKey: Constants.Keys.kDefaultsMapStyle)
        defaults.setInteger(Constants.Values.vDefaultsMaxMapCache, forKey: Constants.Keys.kDefaultsMaxMapCache)
        defaults.removeObjectForKey(Constants.Keys.kDefaultsOfflineMaps)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    struct OfflineMaps
    {
        //Private storage for computed property
        static private var _namedMaps = [String : DownloadedMap]()
        static private var once = dispatch_once_t()
        
        //Cache of downloaded maps
        static var namedMaps: [String : DownloadedMap]
        {
            get
            {
                //Populate the maps dictionary the first time it is requested
                dispatch_once(&once) {
                    if let maps = self.maps
                    {
                        for map in maps
                        {
                            self._namedMaps[map.name] = map
                        }
                    }
                }
                return _namedMaps
            }
        }
        
        // Get/set all the downloaded maps
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
                    _namedMaps = [String : DownloadedMap]()
                    for map in maps
                    {
                        _namedMaps[map.name] = map
                        codedMaps.append(NSKeyedArchiver.archivedDataWithRootObject(map))
                    }
                    NSUserDefaults.standardUserDefaults().setObject(codedMaps, forKey: Constants.Keys.kDefaultsOfflineMaps)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
        }
        
        // Add a map to the stored maps and to the cache
        static func addMap(map: DownloadedMap)
        {
            var codedMaps = NSUserDefaults.standardUserDefaults().objectForKey(Constants.Keys.kDefaultsOfflineMaps) as? [NSData]
            if codedMaps == nil
            {
                codedMaps = [NSData]()
            }
            
            _namedMaps[map.name] = map
            codedMaps!.append(NSKeyedArchiver.archivedDataWithRootObject(map))
            NSUserDefaults.standardUserDefaults().setObject(codedMaps, forKey: Constants.Keys.kDefaultsOfflineMaps)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        //Directly set the cached maps values minus the removed map as the new maps array
        //Only one [Map] -> [NSData]
        static func removeMap(map: DownloadedMap)
        {
            _namedMaps.removeValueForKey(map.name)
            self.maps = [DownloadedMap](_namedMaps.values)
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