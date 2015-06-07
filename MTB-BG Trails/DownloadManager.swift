//
//  DownloadManager.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 6/5/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation
import IDDataCache

class DownloadManager
{
    class TileDownloadManager
    {
        let urlTemplate: String
        let coordinatesForZ: [Int : ((Int, Int), (Int, Int), (Int, Int))]
        let dataCacheName: String
        
        let progressUpdateHandler: ((Double) -> Void)?
        let completionHandler: (() -> Void)?
        
        private let downloadTasksTotal: Double
        private var downloadTasksLeft: Double
        private var downloadTasksSuccessful: Double
        
        //A progress update notification should be sent at each whole % progress
        //Count how many more tasks to notify
        private let downloadTasksBetweenUpdates: Double
        private var downloadTasksToUpdateLeft: Double
        
        private let serialSessionSyncQueue = dispatch_queue_create("com.techLight.mtb-bg.downloadManagerSessionSyncQueue", DISPATCH_QUEUE_SERIAL)
        private var cache: IDDataCache!
        
        convenience init(dataCacheName: String, urlTemplate: String, coordinatesForZ: [Int : ((Int, Int), (Int, Int), (Int, Int))])
        {
            self.init(dataCacheName: dataCacheName,  urlTemplate: urlTemplate, coordinatesForZ: coordinatesForZ, progressUpdateHandler: nil, completionHandler: nil)
        }
        
        init(dataCacheName: String, urlTemplate: String, coordinatesForZ: [Int : ((Int, Int), (Int, Int), (Int, Int))], progressUpdateHandler: ((Double) -> Void)?, completionHandler: (() -> Void)?)
        {
            self.dataCacheName = dataCacheName
            self.urlTemplate = urlTemplate
            self.coordinatesForZ = coordinatesForZ
            
            self.progressUpdateHandler = progressUpdateHandler
            self.completionHandler = completionHandler
            
            self.cache = IDDataCache.sharedNamedPersistentInstance(self.dataCacheName)
            
            var totalTiles = 0
            
            for z in coordinatesForZ.keys
            {
                let ((nwx, nwy), (nex, _), (_, swy)) = coordinatesForZ[z]!
                let xSpan = (nex - nwx) + 1
                let ySpan = (swy - nwy) + 1
                
                totalTiles += xSpan * ySpan
            }
            
            downloadTasksTotal = Double(totalTiles)
            downloadTasksLeft = Double(totalTiles)
            downloadTasksSuccessful = 0
            
            var percent = Double(downloadTasksTotal) / 100.0
            if percent < 1
            {
                percent = 1
            }

            
            downloadTasksBetweenUpdates = percent
            downloadTasksToUpdateLeft = downloadTasksBetweenUpdates
        }
        
        func startDownload(maxHTTPConnections: Int = 2)
        {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfig.HTTPMaximumConnectionsPerHost = maxHTTPConnections
            sessionConfig.timeoutIntervalForRequest = 45
            let session = NSURLSession(configuration: sessionConfig)
            
            for z in coordinatesForZ.keys
            {
                let ((nwx, nwy), (nex, _), (_, swy)) = coordinatesForZ[z]!
                
                for x in nwx...nex
                {
                    for y in nwy...swy
                    {
                        let tileURL = String(format: urlTemplate, z, x, y)
                        let request = NSMutableURLRequest(URL: NSURL(string: tileURL)!)
                        let headTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                            dispatch_async(self.serialSessionSyncQueue) {
                                self.downloadTasksLeft--
                                self.downloadTasksToUpdateLeft--
                                
                                if data != nil
                                {
                                    self.downloadTasksSuccessful++
                                    self.cache.storeData(data, forKey: tileURL)
                                } else
                                {
                                    println("Download error at \(tileURL)" + error.localizedDescription)
                                }
                                
                                if self.downloadTasksToUpdateLeft < 1
                                {
                                    if let progressUpdateHandler = self.progressUpdateHandler
                                    {
                                        dispatch_sync(dispatch_get_main_queue()) {
                                            progressUpdateHandler(1 - (self.downloadTasksLeft / self.downloadTasksTotal))
                                        }
                                    }
                                    
                                    self.downloadTasksToUpdateLeft += self.downloadTasksBetweenUpdates
                                }
                                
                                if self.downloadTasksLeft <= 0
                                {
                                    if let completionHandler = self.completionHandler
                                    {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            completionHandler()
                                        }
                                    }
                                }
                            }
                        }
                        headTask.resume()
                    }
                }
            }
        }
    }
}