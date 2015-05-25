//
//  TrailDetailsTableController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/24/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit

class TrailDetailsTableController: UITableViewController
{

    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var ascentLabel: UILabel!
    @IBOutlet weak var effortLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var tarmacLabel: UILabel!
    @IBOutlet weak var roadsLabel: UILabel!
    @IBOutlet weak var trailsLabel: UILabel!
    @IBOutlet weak var ascentProfileView: TrailAscentProfileView!
    
    var trail: Trail!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let trail = self.trail
        {
            ascentProfileView.track = trail.mainTrack
            ascentProfileView.setNeedsDisplay()
            
            if let length = trail.length
            {
                lengthLabel.text = "\(length)km"
            } else
            {
                lengthLabel.text = "n/a"
            }
            
            if let ascent = trail.ascent
            {
                ascentLabel.text = "\(ascent)m"
            } else
            {
                ascentLabel.text = "n/a"
            }
            
            if let stren = trail.strenuousness
            {
                effortLabel.text = "\(stren)"
            } else
            {
                effortLabel.text = "n/a"
            }
            
            if let difficulty = trail.difficulty
            {
                difficultyLabel.text = ""
                for diff in difficulty
                {
                    difficultyLabel.text! += Constants.Values.vTrailDifficultyClasses[diff] + " "
                }
            } else
            {
                difficultyLabel.text = "n/a"
            }
            
            if let duration = trail.duration
            {
                durationLabel.text = duration
            } else
            {
                durationLabel.text = "n/a"
            }
            
            if let food = trail.food
            {
                foodLabel.text = food
            } else
            {
                foodLabel.text = "n/a"
            }
            
            if let water = trail.water
            {
                waterLabel.text = water
            } else
            {
                waterLabel.text = "n/a"
            }
            
            if let terrains = trail.terrains
            {
                if let tarmac = terrains[Constants.Keys.kTrailTerrainTarmac]
                {
                    tarmacLabel.text = "\(tarmac)km"
                } else
                {
                    tarmacLabel.text = "n/a"
                }
                
                if let roads = terrains[Constants.Keys.kTrailTerrainRoads]
                {
                    roadsLabel.text = "\(roads)km"
                } else
                {
                    roadsLabel.text = "n/a"
                }
                
                if let trails = terrains[Constants.Keys.kTrailTerrainTrails]
                {
                    trailsLabel.text = "\(trails)km"
                } else
                {
                    trailsLabel.text = "n/a"
                }
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
