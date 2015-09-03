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
    let cache = IDDataCache.sharedNamedInstance(Constants.Keys.kCacheMapTemporary)
    let operationQueue = NSOperationQueue()
    
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: ((NSData?, NSError?) -> Void))
    {
        
        let urlstr = URLForTilePath(path).absoluteString
        
        //First try to find the tile in the temporary cache
        if let cachedData = self.cache.dataFromDiskCacheForKey(urlstr)
        {
            let newData = markXYZ(cachedData, path: path)
            print("Map tile found in temporary cache")
            result(newData, nil)
        } else
        {
            //Then look in the downloaded maps persistent cache
            for map in Settings.OfflineMaps.namedMaps.values.array
            {
                if let ((nwx, nwy), (nex, ney), (swx, swy)) = map.coordinatesPerZ[path.z]
                {
                    if (path.x >= nwx) && (path.x <= nex) && (path.y >= nwy) && (path.y <= swy)
                    {
                        let persistentCache = IDDataCache.sharedNamedPersistentInstance(map.dataCacheName)
                        if let data = persistentCache.dataFromDiskCacheForKey(urlstr)
                        {
                            print("Map til found in persistent storage")
                            self.cache.storeData(data, forKey: urlstr)
                            result(data, nil)
                            return
                        }
                    }
                }
            }
            
            //Finally try to download it
            let request = NSURLRequest(URL: URLForTilePath(path))
            NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue) { response, data, error in
                if data != nil
                {
                    print("Map tile downloaded online")
                    self.cache.storeData(data, forKey: urlstr)
                    let newData = self.markXYZ(data, path: path)
                    result(newData, nil)
                    return
                } else
                {
                    print("Unable to retrieve map tile \(urlstr)")
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
        let text = NSAttributedString(string: String(format: "X=%d\nY=%d\nZ=%d", path.x, path.y, path.z), attributes: textAttributes)
        text.drawInRect(rect)
        
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIImagePNGRepresentation(drawnImage)
    }
}
