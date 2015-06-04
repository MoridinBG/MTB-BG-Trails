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
    let cache = IDDataCache(namespace: Constants.Keys.kCacheMapTemporary)
    let operationQueue = NSOperationQueue()
    
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: ((NSData!, NSError!) -> Void)!)
    {
        
        let urlstr = URLForTilePath(path).absoluteString!
        if let cachedData = self.cache.dataFromDiskCacheForKey(urlstr)
        {
            let newData = markXYZ(cachedData, path: path)
//            println("Cached")
            result(newData, nil)
        } else
        {
            let request = NSURLRequest(URL: URLForTilePath(path))
            println("Not cached")
            NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue) { response, data, error in
                if data != nil
                {
                    self.cache.storeData(data, forKey: urlstr)
                    let newData = self.markXYZ(data, path: path)
                    result(newData, nil)
                    return
                } else
                {
                    println("Panic")
                }
                

                result(data, error)
            }
        }
    }
    
    private func markXYZ(data: NSData, path: MKTileOverlayPath) -> NSData
    {
        let sz = self.tileSize
        let rect = CGRectMake(0, 0, sz.width, sz.height)
        UIGraphicsBeginImageContext(sz)
        let context = UIGraphicsGetCurrentContext()
        
        let image = UIImage(data: data)
        image?.drawInRect(rect)
        
        UIColor.grayColor().setStroke()
        CGContextSetLineWidth(context, 1)
        CGContextStrokeRect(context, CGRectMake(0, 0, sz.width, sz.height))
        
        let font = UIFont.systemFontOfSize(17)
        let textColour = UIColor.blackColor()
        let textAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : textColour]
        var text = NSAttributedString(string: String(format: "X=%d\nY=%d\nZ=%d", path.x, path.y, path.z), attributes: textAttributes)
        text.drawInRect(rect)
        
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIImagePNGRepresentation(drawnImage)
    }
}
