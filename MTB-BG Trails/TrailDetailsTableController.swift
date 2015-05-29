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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var tarmacLabel: UILabel!
    @IBOutlet weak var roadsLabel: UILabel!
    @IBOutlet weak var trailsLabel: UILabel!
    @IBOutlet weak var ascentProfileView: TrailAscentProfileView!
    
    var trail: Trail!
    
    private var hiddenRows = [Int]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 89
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let trail = self.trail
        {
            ascentProfileView.track = trail.mainTrack
            ascentProfileView.setNeedsDisplay()
            
            if let name = trail.name
            {
                nameLabel.text = name
            }
            
            if let link = trail.link
            {
                let link = NSMutableAttributedString(string: "@MTB Weб Page")
                link.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, link.length))
                linkLabel.attributedText = link
            }
            
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
                hiddenRows.append(4)
            }
            
            if let duration = trail.duration
            {
                durationLabel.text = duration
            } else
            {
                hiddenRows.append(5)
            }
            
            if let food = trail.food
            {
                foodLabel.text = food
            } else
            {
                hiddenRows.append(6)
            }
            
            if let water = trail.water
            {
                waterLabel.text = water
            } else
            {
                hiddenRows.append(7)
            }
            
            if let terrains = trail.terrains
            {
                if let tarmac = terrains[Constants.Keys.kTrailTerrainTarmac]
                {
                    tarmacLabel.text = "\(tarmac)km"
                }
                
                if let roads = terrains[Constants.Keys.kTrailTerrainRoads]
                {
                    roadsLabel.text = "\(roads)km"
                }
                
                if let trails = terrains[Constants.Keys.kTrailTerrainTrails]
                {
                    trailsLabel.text = "\(trails)km"
                }
            } else
            {
                hiddenRows.append(8)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        var hideRow = false
        
        for index in hiddenRows
        {
            if indexPath.row == index
            {
                hideRow = true
            }
        }
        
        if hideRow
        {
            return 0
        } else
        {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        println(indexPath.row)
        if indexPath.row == 3 && trail.link != nil
        {
            let sharedApp = UIApplication.sharedApplication()
            sharedApp.openURL(trail.link!)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
