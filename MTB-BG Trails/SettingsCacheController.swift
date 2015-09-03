//
//  SettingsCacheController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 6/2/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import IDDataCache

class SettingsCacheController: UITableViewController
{

    @IBOutlet weak var currentCacheSize: UILabel!
    @IBOutlet weak var maxCacheSize: UILabel!
    
    let cacheFormat = "%dMB"
    let cache = IDDataCache.sharedNamedInstance(Constants.Keys.kCacheMapTemporary)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        maxCacheSize.text = String(format: cacheFormat, (Settings.Cache.maxMapTileCache / 1024) / 1024)
        
        cache.calculateSizeWithCompletionBlock() { (toalCount, fileSize) in
            dispatch_async(dispatch_get_main_queue()) {
                self.currentCacheSize.text = String(format: self.cacheFormat, (fileSize / 1024) / 1024)
            }
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.section == 1 && indexPath.row == 1
        {
            switch Settings.Maps.style
            {
                case .AppleHybrid, .AppleSatellite, .AppleStandard:
                    cell.selectionStyle = .None
                    cell.userInteractionEnabled = false
                    cell.textLabel!.enabled = false
                default: ()
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0 && indexPath.row == 2
        {
            cache.clearDiskWithCompletion() {
                self.cache.calculateSizeWithCompletionBlock() { (toalCount, fileSize) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.currentCacheSize.text = String(format: self.cacheFormat, (fileSize / 1024) / 1024)
                    }
                }
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
    {
		if identifier == Constants.Keys.kSegueIDMapsDownloadSettings
		{
			switch Settings.Maps.style
			{
				case .AppleHybrid, .AppleSatellite, .AppleStandard:
					return false
				default: ()
			}
		}
        
        return true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
