//
//  Constants.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

var GlobalMainQueue: dispatch_queue_t
{
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t
{
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t
{
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)
}

var GlobalUtilityQueue: dispatch_queue_t
{
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t
{
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
}

struct Constants
{
	struct Keys
	{
        static let kCellIdTracks               = "TrackCell"
        static let kCellIdTracksHeader         = "TracksHeaderCell"

        static let kSegueIdTracksFilterPopover = "TracksFilterPopoverSegue"
        static let kSegueIdTrailDetails        = "trailDetails"
        static let kSegueIdTrailDetailsTable   = "trailDetailsTable"

        static let kTrailTerrainTarmac         = "асфалт"
        static let kTrailTerrainRoads          = "черни пътища"
        static let kTrailTerrainTrails         = "пътеки"
        
        static let kDefaultsMapStyle           = "defaults.mapStyle"
        
        static let kCacheMapGeneral            = "mapcache.general"
        static let kCacheMapPersistant         = "mapcache.persistant"
	}
    
	struct Values
	{
        static let vJSONTrailsURL              = "https://raw.githubusercontent.com/karamanolev/mtb-index/master/preprocessor/input.json"
        static let vJSONTrailsFilename         = "trails.json"

        static let vTrailDifficultyClasses     = ["NA", "R1", "R2", "R3", "F", "T1", "T2", "T3", "T4", "T5", "X", "FX"]
        
        static let vStoryboardSettings         = "Settings"
        
        static let vMapTilesOCM                = "http://a.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
        static let vMapTilesOSM                = "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
        static let vMapTilesOSMOut             = "http://a.tile.thunderforest.com/outdoors/{z}/{x}/{y}.png"
        static let vMapTilesOSMLand            = "http://a.tile.thunderforest.com/landscape/{z}/{x}/{y}.png"
        
        static let vDefaultsMapStyleOCM        = "ocm"
        static let vDefaultsMapStyleOSMStd     = "osm.standard"
        static let vDefaultsMapStyleOSMOut     = "osm.outdoors"
        static let vDefaultsMapStyleOSMLand    = "osm.landscape"
        
        static let vDefaultsMapStyleAppleStd   = "apple.standard"
        static let vDefaultsMapStyleAppleSat   = "apple.satellite"
        static let vDefaultsMapStyleAppleHyb   = "apple.hybride"
	}
}