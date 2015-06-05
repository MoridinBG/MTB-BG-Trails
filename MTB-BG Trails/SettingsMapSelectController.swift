//
//  SettingsMapSelectController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/28/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit

class SettingsMapSelectController: UITableViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    //Put a checkmark on the row of the currently set map style
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let selectedIndex = indexPathForCurrentStyle()
        if let cell = tableView.cellForRowAtIndexPath(selectedIndex)
        {
            cell.accessoryType = .Checkmark
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Move the checkmark to the currently selected map style and store it in settings
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let oldIndex = indexPathForCurrentStyle()
        
        switch indexPath.section
        {
            case 0:
                switch indexPath.row
                {
                    case 0:
                        Settings.Maps.style = .OpenCycleMap
                    case 1:
                        Settings.Maps.style = .OpenStreetMapStandard
                    case 2:
                        Settings.Maps.style = .OpenStreetMapOutdoors
                    case 3:
                        Settings.Maps.style = .OpenStreetMapLandscae
                    
                    default:
                        println("Setting unimplemented OpenStreetMap map style in Map Style in Settings")
                }
            
            case 1:
                switch indexPath.row
                {
                case 0:
                    Settings.Maps.style = .AppleStandard
                case 1:
                    Settings.Maps.style = .AppleSatellite
                case 2:
                    Settings.Maps.style = .AppleHybrid
                default:
                    println("Setting unimplemented Apple map style in Map Style in Settings")
                }
            
            default:
                println("Setting unimplemented map style in Map Style in Settings")
        }
        
        if oldIndex != indexPath
        {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            tableView.cellForRowAtIndexPath(oldIndex)?.accessoryType = .None
        }
    }

    //Generate the index path in the table view of the row associated with a map style
    private func indexPathForCurrentStyle() -> NSIndexPath
    {
        let currentStyle = Settings.Maps.style
        let index: NSIndexPath
        
        switch currentStyle
        {
            case .OpenCycleMap:
                index = NSIndexPath(forRow: 0, inSection: 0)
                
            case .OpenStreetMapStandard:
                index = NSIndexPath(forRow: 1, inSection: 0)
                
            case .OpenStreetMapOutdoors:
                index = NSIndexPath(forRow: 2, inSection: 0)
                
            case .OpenStreetMapLandscae:
                index = NSIndexPath(forRow: 3, inSection: 0)
                
                
                
            case .AppleStandard:
                index = NSIndexPath(forRow: 0, inSection: 1)
                
            case .AppleSatellite:
                index = NSIndexPath(forRow: 1, inSection: 1)
                
            case .AppleHybrid:
                index = NSIndexPath(forRow: 2, inSection: 1)
        }
        
        return index
    }
    
}
