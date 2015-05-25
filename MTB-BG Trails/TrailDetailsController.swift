//
//  TrailDetailsController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/23/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit

class TrailDetailsController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableContainer: UIScrollView!
    @IBOutlet var mapHeight: NSLayoutConstraint!
    
    var detailsTable: TrailDetailsTableController!
    var trail: Trail!
    
    var isMapZoomed = false
    var isRenderingOptionals = true
    
    
    @IBAction func mapClicked(sender: UIButton)
    {
        isMapZoomed = true
        UIView.animateWithDuration(1, animations: {
            self.containerView.bringSubviewToFront(self.mapView)
            self.containerView.removeConstraint(self.mapHeight)
            self.mapView.layoutIfNeeded()
            },
            completion: { (success) in
                self.fitTrailInMap(self.trail)
        })
    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        if isMapZoomed
        {
            isMapZoomed = false
            UIView.animateWithDuration(1, animations: {
                self.containerView.bringSubviewToFront(self.tableContainer)
                self.containerView.addConstraint(self.mapHeight)
                self.mapView.layoutIfNeeded()
                },
                completion: { (success) in
                    self.fitTrailInMap(self.trail)
            })
        } else
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        let trails = trail.gpsTracks()
        for track in trails
        {
            mapView.addOverlay(track.trackPolyline)
        }
        fitTrailInMap(trail)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let segueId = segue.identifier
        {
            if segueId == Constants.Keys.kSegueIdTrailDetailsTable
            {
                self.detailsTable = segue.destinationViewController as! TrailDetailsTableController
                self.detailsTable.trail = trail
            }
        }
    }

}
