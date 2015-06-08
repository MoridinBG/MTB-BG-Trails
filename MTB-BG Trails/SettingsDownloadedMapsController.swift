//
//  SettingsDownloadedMapsController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 6/8/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import IDDataCache

class SettingsDownloadedMapsController: UITableViewController
{

    private var maps = Settings.OfflineMaps.namedMaps.values.array
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return maps.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Keys.kCellIdDownloadedMap, forIndexPath: indexPath) as! UITableViewCell
        let map = maps[indexPath.row]
        cell.textLabel?.text = map.name
        
        let cache = IDDataCache.sharedNamedPersistentInstance(map.dataCacheName)
        cache.calculateSizeWithCompletionBlock() { (fileCount, totalSize) -> Void in
            var sizeString = ""
            if totalSize < 1024
            {
                sizeString = "\(totalSize) bytes"
            } else if totalSize >= 1024 && totalSize < 838860
            {
                let size = Double(totalSize) / 1024.0
                sizeString = String(format: "%.2fKB", size)
            } else if totalSize >= 838860 && totalSize < 858993459
            {
                let size = (Double(totalSize) / 1024.0) / 1024.0
                sizeString = String(format: "%.2fMB", size)
            } else if totalSize >= 858993459
            {
                let size = ((Double(totalSize) / 1024.0) / 1024.0) / 1024.0
                sizeString = String(format: "%.2fGB", size)
            }
            
            cell.detailTextLabel?.text = sizeString
        }
        

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let map = maps[indexPath.row]
            IDDataCache.sharedNamedPersistentInstance(map.name).clearDisk()
            Settings.OfflineMaps.removeMap(map)
            maps.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
