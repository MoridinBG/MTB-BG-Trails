//
//  SettingsDownloadOffline.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 6/3/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit

class SettingsDownloadOffline: MapViewCommon, NSURLSessionTaskDelegate
{

    @IBOutlet weak var minZoom: UISlider!
    @IBOutlet weak var maxZoom: UISlider!
    
    @IBOutlet weak var minZoomLabel: UILabel!
    @IBOutlet weak var maxZoomLabel: UILabel!
    
    @IBOutlet weak var toDownload: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    private var downloadSizeFormat: String!
    
    //UISlider works in Floats and not Doubles
    private var oldMinZoom: Float = -1
    private var oldMaxZoom: Float = -1
    private var zoomStep: Float = 1
    
    private var totalTileSize: Int64 = 0
    private var tilesForTask = [NSURLSessionTask : Int64]()
    
    //Used to barrier access to shared resources
    private let concurrentDownloadSizeQueue = dispatch_queue_create("com.techLight.mtb-bg.settingsDownloadSizeQueue", DISPATCH_QUEUE_SERIAL)
    
    private var headTasks: Set<NSURLSessionTask> = Set<NSURLSessionTask>()
    {
        didSet
        {
            if headTasks.count == 0
            {
                dispatch_async(concurrentDownloadSizeQueue) {
                    dispatch_sync(dispatch_get_main_queue()) {
                        println("Updating \(self.totalTileSize)")
                        let sizeMB = String(format: "%.1f", (Double(self.totalTileSize) / 1024.0) / 1024.0)
                        self.toDownload.text = String(format: self.downloadSizeFormat, sizeMB)
                    }
                }
            }
        }
    }
    
    @IBAction func minZoomChanged(sender: UISlider)
    {
        let newStep = roundf((minZoom.value) / zoomStep)
        minZoom.value = newStep * zoomStep
        
        if minZoom.value == oldMinZoom
        {
            return
        } else
        {
            oldMinZoom = minZoom.value
        }
        
        maxZoom.minimumValue = minZoom.value
        minZoomLabel.text = "\(Int(minZoom.value))"
        
        calculateDownloadSize()
    }
    
    @IBAction func maxZoomChanged(sender: UISlider)
    {
        let newStep = roundf((maxZoom.value) / zoomStep)
        maxZoom.value = newStep * zoomStep
        
        if maxZoom.value == oldMaxZoom
        {
            return
        } else
        {
            oldMaxZoom = maxZoom.value
        }
        
        minZoom.maximumValue = maxZoom.value
        maxZoomLabel.text = "\(Int(maxZoom.value))"
        
        calculateDownloadSize()
    }
    
    
    @IBAction func download(sender: UIButton)
    {
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        downloadSizeFormat = toDownload.text!
        
        maxZoom.maximumValue = Float(Constants.Values.vMapMaxZoomLevel)
        minZoom.maximumValue = Float(Constants.Values.vMapMaxZoomLevel)
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool)
    {
        calculateDownloadSize()
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
    {
        if let response = task.response
        {
            dispatch_async(concurrentDownloadSizeQueue) {
                println("Setting")
                let size = response.expectedContentLength * self.tilesForTask[task]!
                self.totalTileSize += size
                
                self.headTasks.remove(task)
                self.tilesForTask.removeValueForKey(task)
            }
        } else
        {
            println("Canceled")
            dispatch_async(concurrentDownloadSizeQueue) {
                self.headTasks.remove(task)
                self.tilesForTask.removeValueForKey(task)
            }
        }
    }
    
    private func calculateDownloadSize()
    {
        dispatch_sync(concurrentDownloadSizeQueue) {
            println("Canceling \(self.headTasks.count)")
            self.totalTileSize = 0
            for headTask in self.headTasks
            {
                headTask.cancel()
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            let hourglass = "\u{231B}" //Hourglass unicode symbol
            self.toDownload.text = String(format: self.downloadSizeFormat, hourglass)
        }
        
        let nwPoint = CGPointMake(mapView.bounds.origin.x, mapView.bounds.origin.y)
        let nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y)
        
        let swPoint = CGPointMake(mapView.bounds.origin.x, mapView.bounds.origin.y + mapView.bounds.size.height)
        let sePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y + mapView.bounds.size.height)
        
        let neCoord = mapView.convertPoint(nePoint, toCoordinateFromView: mapView)
        let nwCoord = mapView.convertPoint(nwPoint, toCoordinateFromView: mapView)
        
        let swCoord = mapView.convertPoint(swPoint, toCoordinateFromView: mapView)
        let seCoord = mapView.convertPoint(sePoint, toCoordinateFromView: mapView)
        
        let minZ = Int(minZoom.value)
        let maxZ = Int(maxZoom.value)
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.HTTPMaximumConnectionsPerHost = 2
        sessionConfig.timeoutIntervalForRequest = 45
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        for z in minZ...maxZ
        {
        
            let (nwX, nwY) = coordZToXY(nwCoord, z: z)
            let (neX, neY) = coordZToXY(neCoord, z: z)
        
            let (swX, swY) = coordZToXY(swCoord, z: z)
            let (seX, seY) = coordZToXY(seCoord, z: z)
            
            let xSpan = neX - nwX
            let ySpan = swY - nwY

            let tileURL = String(format: Constants.Values.vMapTilesFormatOSM, z, (nwX + neX) / 2, (nwY + swY) / 2)
            let request = NSMutableURLRequest(URL: NSURL(string: tileURL)!)
            request.HTTPMethod = "Head"
            let headTask = session.dataTaskWithRequest(request)
            dispatch_async(concurrentDownloadSizeQueue) {
                self.headTasks.insert(headTask)
                self.tilesForTask[headTask] = Int64(xSpan * ySpan)
            }
            
            headTask.resume()
        }
        
    }
    
    private func coordZToXY(coord: CLLocationCoordinate2D, z: Int) -> (x: Int, y: Int)
    {
        let n = pow(2, Double(z))
        let latRad = coord.latitude * M_PI / 180.0
        let x = Int(floor((coord.longitude + 180.0) / 360.0 * n))
        let y = Int(floor((1.0 - log( tan(latRad) + 1.0 / cos(latRad)) / M_PI) / 2.0 * n))
        
        return (x, y)
    }
    
}
