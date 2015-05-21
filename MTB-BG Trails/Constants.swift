//
//  Constants.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

struct Constants
{
	struct Keys
	{
        static let kCellIdTracks               = "TrackCell"
        static let kCellIdTracksHeader         = "TracksHeaderCell"

        static let kSegueIdTracksFilterPopover = "TracksFilterPopoverSegue"
	}
	struct Values
	{
        static let vJSONTrailsURL              = "https://raw.githubusercontent.com/karamanolev/mtb-index/master/preprocessor/input.json"
        static let vJSONTrailsFilename         = "trails.json"

        static let vTrailDifficultyClasses     = ["NA", "R1", "R2", "R3", "F", "T1", "T2", "T3", "T4", "T5", "X", "FX"]
	}
}