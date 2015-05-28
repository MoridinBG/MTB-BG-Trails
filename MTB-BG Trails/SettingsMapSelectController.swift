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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let oldIndex = indexPathForCurrentStyle()
        
        switch indexPath.section
        {
            case 0:
                switch indexPath.row
                {
                    case 0:
                        defaults.setObject(Constants.Values.vDefaultsMapStyleOCM, forKey: Constants.Keys.kDefaultsMapStyle)
                    case 1:
                        defaults.setObject(Constants.Values.vDefaultsMapStyleOSMStd, forKey: Constants.Keys.kDefaultsMapStyle)
                    case 2:
                        defaults.setObject(Constants.Values.vDefaultsMapStyleOSMOut, forKey: Constants.Keys.kDefaultsMapStyle)
                    case 3:
                        defaults.setObject(Constants.Values.vDefaultsMapStyleOSMLand, forKey: Constants.Keys.kDefaultsMapStyle)
                    
                    default:
                        println("Setting unimplemented OpenStreetMap map style in Map Style in Settings")
                }
            
            case 1:
                switch indexPath.row
                {
                case 0:
                    defaults.setObject(Constants.Values.vDefaultsMapStyleAppleStd, forKey: Constants.Keys.kDefaultsMapStyle)
                case 1:
                    defaults.setObject(Constants.Values.vDefaultsMapStyleAppleSat, forKey: Constants.Keys.kDefaultsMapStyle)
                case 2:
                    defaults.setObject(Constants.Values.vDefaultsMapStyleAppleHyb, forKey: Constants.Keys.kDefaultsMapStyle)
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

    private func indexPathForCurrentStyle() -> NSIndexPath
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentStyle = defaults.objectForKey(Constants.Keys.kDefaultsMapStyle) as! String
        let index: NSIndexPath
        
        switch currentStyle
        {
            case Constants.Values.vDefaultsMapStyleOCM:
                index = NSIndexPath(forRow: 0, inSection: 0)
                
            case Constants.Values.vDefaultsMapStyleOSMStd:
                index = NSIndexPath(forRow: 1, inSection: 0)
                
            case Constants.Values.vDefaultsMapStyleOSMOut:
                index = NSIndexPath(forRow: 2, inSection: 0)
                
            case Constants.Values.vDefaultsMapStyleOSMLand:
                index = NSIndexPath(forRow: 3, inSection: 0)
                
                
                
            case Constants.Values.vDefaultsMapStyleAppleStd:
                index = NSIndexPath(forRow: 0, inSection: 1)
                
            case Constants.Values.vDefaultsMapStyleAppleSat:
                index = NSIndexPath(forRow: 1, inSection: 1)
                
            case Constants.Values.vDefaultsMapStyleAppleHyb:
                index = NSIndexPath(forRow: 2, inSection: 1)
                
            default:
                println("Weird value for Map Style in Settings")
                index = NSIndexPath(forRow: -1, inSection: -1)
        }
        
        return index
    }
    
}
