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

    // MARK: - Outlet properties
    @IBOutlet weak var minZoom: UISlider!
    @IBOutlet weak var maxZoom: UISlider!
    
    @IBOutlet weak var minZoomLabel: UILabel!
    @IBOutlet weak var maxZoomLabel: UILabel!
    
    @IBOutlet weak var toDownload: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    // MARK: - Properties
    
    private var downloadSizeStringFormat: String!
    private var tileServerTemplate: String!
    
    //UISlider works in Floats and not Doubles
    private var oldMinZoom: Float = -1
    private var oldMaxZoom: Float = -1
    private var zoomStep: Float = 1
    
    private var totalTileSize: Int64 = 0
    private var tilesForTask = [NSURLSessionTask : Int64]()
    private var tileRangesPerLevel = [Int : ((Int, Int), (Int, Int), (Int, Int))]()
    
    //Used to sync access to shared resources
    private let serialSessionSyncQueue = dispatch_queue_create("com.techLight.mtb-bg.settingsDownloadSessionSyncQueue", DISPATCH_QUEUE_SERIAL)
    
    private var headTasks: Set<NSURLSessionTask> = Set<NSURLSessionTask>()
    {
        didSet
        {
            if headTasks.count == 0
            {
                dispatch_async(serialSessionSyncQueue) {
                    //I think the main queue dispatch should be sync, so  that the outer custom queue dispatch wouldn't return (and advance the queue) before the main one is finished
                    dispatch_sync(dispatch_get_main_queue()) {
                        
                        let sizeMB = String(format: "%.1f", (Double(self.totalTileSize) / 1024.0) / 1024.0)
                        self.toDownload.text = String(format: self.downloadSizeStringFormat, sizeMB)
                        
                        self.setUIUserInteractionEnabled(true)
                    }
                }
            }
        }
    }
    
    // MARK: - Outlet actions
    
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

        //Make sure the user really want's to download this huge data set
        if (Double(self.totalTileSize) / 1024.0) / 1024.0 > 512
        {
            let alert = UIAlertController(title: "Trying to download a large mapset", message: "You are trying to download a very large mapset. Are you sure you need it? This can be very taxing for the voluntarily ran map servers and take large amounts of storage on your device.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Yes", style: .Default) { (action: UIAlertAction!) in
                self.askForMapsetNameAndDownload()
                
                self.setUIUserInteractionEnabled(false)
            }
            alert.addAction(okAction)
            alert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else
        {
            askForMapsetNameAndDownload()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        downloadSizeStringFormat = toDownload.text!
        
        maxZoom.maximumValue = Float(Constants.Values.vMapMaxZoomLevel)
        minZoom.maximumValue = Float(Constants.Values.vMapMaxZoomLevel)
        
        //Set URL template for downloadable map types.
        //This screen should be inaccessible if a non-downloadable map type is selected
        switch Settings.Maps.style
        {
            case .OpenCycleMap:
                tileServerTemplate = Constants.Values.vMapTilesFormatOCM
            case .OpenStreetMapStandard:
                tileServerTemplate = Constants.Values.vMapTilesFormatOSM
            case .OpenStreetMapOutdoors:
                tileServerTemplate = Constants.Values.vMapTilesFormatOSMOut
            case .OpenStreetMapLandscae:
                tileServerTemplate = Constants.Values.vMapTilesFormatOSMLand
            
            default: ()
        }
    }

    // MARK: - MKMapViewDelegate
    
    //Recalculate approximate download size
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool)
    {
        calculateDownloadSize()
    }
    
    // MARK: - NSURLSessionTaskDelegate
    
    //Handle session task lifecycle. Delegate, instead of a closure, because the closure doesn't have a reference to the session task itself
    //(needed to remove itself from the collections)
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
    {
        if let response = task.response
        {
            dispatch_async(serialSessionSyncQueue) {
                let size = response.expectedContentLength * self.tilesForTask[task]!
                self.totalTileSize += size
                
                self.headTasks.remove(task)
                self.tilesForTask.removeValueForKey(task)
            }
        //Usually - canceled
        } else
        {
            dispatch_async(serialSessionSyncQueue) {
                self.headTasks.remove(task)
                self.tilesForTask.removeValueForKey(task)
            }
        }
    }
    
    // MARK: - Private
    
    private func askForMapsetNameAndDownload()
    {
        let alert = UIAlertController(title: "Mapset name", message: "Enter a name for this mapset", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) in
            let nameField = alert.textFields![0] as! UITextField
            let name = nameField.text
            let uniqueName = NSUUID().UUIDString + name
            let downloadManager = DownloadManager.TileDownloadManager(dataCacheName: uniqueName,
                urlTemplate: self.tileServerTemplate,
                coordinatesForZ: self.tileRangesPerLevel,
                progressUpdateHandler: { (progress) -> Void in
                    println("Downloaded \(progress)")
            }, completionHandler: {
                let downloadedMap = DownloadedMap(name: name, dataCacheName: uniqueName, coordinatesPerZ: self.tileRangesPerLevel)
                Settings.OfflineMaps.addMap(downloadedMap)
                self.setUIUserInteractionEnabled(true)
            })
            downloadManager.startDownload(maxHTTPConnections: 2)
        }
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default) { (_) in
            self.setUIUserInteractionEnabled(true)
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func setUIUserInteractionEnabled(enabled: Bool)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.userInteractionEnabled = enabled
            self.minZoom.userInteractionEnabled = enabled
            self.maxZoom.userInteractionEnabled = enabled
            self.downloadButton.userInteractionEnabled = enabled
            self.downloadButton.enabled = enabled
        }
    }
    
    // Very crude at the moment - takes the center tile for each zoom level and uses it as the average size for the entire zoom level
    // Water/grass tiles ~ 100 bytes, cyti tiles ~ 40kb
    //Inaccurate over large regions
    
    //TODO: Take average of several tiles per zoom level
    private func calculateDownloadSize()
    {
        //Cancel all currently running taks
        dispatch_sync(serialSessionSyncQueue) {
            self.totalTileSize = 0
            for headTask in self.headTasks
            {
                headTask.cancel()
            }
            
            self.tileRangesPerLevel.removeAll(keepCapacity: true)
        }
        
        //Provide feedback and prevent download, while calculating
        dispatch_async(dispatch_get_main_queue()) {
            let hourglass = "\u{231B}" //Hourglass unicode symbol while calculating size
            self.toDownload.text = String(format: self.downloadSizeStringFormat, hourglass)
            
            self.downloadButton.enabled = false
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
            
            self.tileRangesPerLevel[z] = ((nwX, nwY), (neX, neY), (swX, swY))
            
            let xSpan = neX - nwX
            let ySpan = swY - nwY

            let tileURL = String(format: tileServerTemplate, z, (nwX + neX) / 2, (nwY + swY) / 2)
            let request = NSMutableURLRequest(URL: NSURL(string: tileURL)!)
            request.HTTPMethod = "Head"
            let headTask = session.dataTaskWithRequest(request)
            dispatch_async(serialSessionSyncQueue) {
                self.headTasks.insert(headTask)
                self.tilesForTask[headTask] = Int64(xSpan * ySpan)
            }
            
            headTask.resume()
        }
        
    }
    
    //Translate a lat/lon coordinate to x,y tile coordinate
    //From OSM wiki
    private func coordZToXY(coord: CLLocationCoordinate2D, z: Int) -> (x: Int, y: Int)
    {
        let n = pow(2, Double(z))
        let latRad = coord.latitude * M_PI / 180.0
        let x = Int(floor((coord.longitude + 180.0) / 360.0 * n))
        let y = Int(floor((1.0 - log( tan(latRad) + 1.0 / cos(latRad)) / M_PI) / 2.0 * n))
        
        return (x, y)
    }
    
}
