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
    let cache = IDDataCache.sharedCache(named: Constants.Keys.kCacheMapTemporary)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let maxCache = NSUserDefaults.standardUserDefaults().integerForKey(Constants.Keys.kDefaultsMaxMapCache)
        maxCacheSize.text = String(format: cacheFormat, (maxCache / 1024) / 1024)
        
        
        cache.calculateSizeWithCompletionBlock() { (toalCount, fileSize) in
            dispatch_async(dispatch_get_main_queue()) {
                self.currentCacheSize.text = String(format: self.cacheFormat, (fileSize / 1024) / 1024)
            }
        }

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

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
