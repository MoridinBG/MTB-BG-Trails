//
//  CachingTileOverlay.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/29/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit
import IDDataCache

class CachingTileOverlay: MKTileOverlay
{
    let cache = IDDataCache(namespace: Constants.Keys.kCacheMapGeneral)
    let operationQueue = NSOperationQueue()
    
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: ((NSData!, NSError!) -> Void)!)
    {
        
        let urlstr = URLForTilePath(path).absoluteString!
        if let cachedData = self.cache.dataFromDiskCacheForKey(urlstr)
        {
            println("Cached")
            result(cachedData, nil)
        } else
        {
            let request = NSURLRequest(URL: URLForTilePath(path))
            println("Not cached")
            NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue) { response, data, error in
                if data != nil
                {
                    self.cache.storeData(data, forKey: urlstr)
                } else
                {
                    println("Panic")
                }
                result(data, error)
            }
        }
    }
}
