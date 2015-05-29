//
//  CachingTileOverlay.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/29/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit

class CachingTileOverlay: MKTileOverlay
{
    let cache = NSCache()
    let operationQueue = NSOperationQueue()
    
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: ((NSData!, NSError!) -> Void)!)
    {
        if let cachedData = self.cache.objectForKey(URLForTilePath(path)) as? NSData
        {
            result(cachedData, nil)
        } else
        {
            let request = NSURLRequest(URL: URLForTilePath(path))
            NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue) { response, data, error in
                self.cache.setObject(data, forKey: self.URLForTilePath(path))
                result(data, error)
            }
        }
    }
}
