//
//  ViewController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit


class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, TrailsLoaderDelegate
{

	private var trails = [Trail]()
	private let trailsLoader = TrailsLoader()
	
	@IBOutlet weak var tracksTable: UITableView!
	@IBOutlet weak var tableScrollView: UIScrollView!
	@IBOutlet weak var mapView: MKMapView!
	
	@IBAction func mapClicked(sender: UIButton)
	{
		self.navigationItem.leftBarButtonItem?.enabled = true
		self.navigationItem.leftBarButtonItem?.tintColor = nil
		
		UIView.animateWithDuration(1, animations: {self.tableScrollView.frame.origin.y += 600}, completion: { (success) in
			self.view.bringSubviewToFront(self.mapView)
		})
	}
	
	@IBAction func backClicked(sender: UIBarButtonItem)
	{
		self.navigationItem.leftBarButtonItem?.enabled = false
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
		
		self.view.bringSubviewToFront(self.tableScrollView)
		UIView.animateWithDuration(1, animations: {
			self.tableScrollView.frame.origin.y -= 600
			}
			, completion: nil)
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		tracksTable.dataSource = self
		tableScrollView.delegate = self
		mapView.delegate = self
		
		self.navigationItem.leftBarButtonItem?.enabled = false
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
		
		trailsLoader.delegate = self
		trailsLoader.loadTrails(NSURL(string:Constants.Values.vJSONTrailsURL)!) { (trails) in
			self.trails = trails
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.tracksTable.reloadData()
			})
		}
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tracksTable.dequeueReusableCellWithIdentifier(Constants.Keys.kCellIdTracks) as! TrailTableCell
		var trail = trails[indexPath.row]
		
		cell.nameLabel.text = trail.name
		cell.nameLabel.type = .Continuous
		cell.nameLabel.scrollDuration = 30.0
		cell.nameLabel.animationCurve = .Linear
		cell.nameLabel.fadeLength = 0
		cell.nameLabel.leadingBuffer = 30.0
		cell.nameLabel.trailingBuffer = 20.0
		
		if let date = trail.date
		{
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "dd.MM.yyyy"
			cell.dateLabel.text = dateFormatter.stringFromDate(date)
		} else
		{
			cell.dateLabel.text = "n/a"
		}
		
		if let length = trail.length
		{
			cell.lengthLabel.text = "\(length)km"
		} else
		{
			cell.lengthLabel.text = "n/a"
		}
		
		if let ascent = trail.ascent
		{
			cell.ascentLabel.text = "\(ascent)m"
		} else
		{
			cell.ascentLabel.text = "n/a"
		}
		
		if let difficulty = trail.difficulty
		{
			cell.diffLabel.text = ""
			for diff in difficulty
			{
				cell.diffLabel.text! += diff + " "
			}
		} else
		{
			cell.diffLabel.text = "n/a"
		}
		
		if let duration = trail.duration
		{
			cell.durationLabel.text = duration
		} else
		{
			cell.durationLabel.text = "n/a"
		}
		
		
		return cell
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return trails.count
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView)
	{
		if scrollView == tableScrollView
		{
			if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height
			{
				scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height)
			}
		}
	}
	
	func allGPXLoaded()
	{
		for trail in trails
		{
			if let gpxRoot = trail.gpxRoot
			{
				for track in gpxRoot.tracks as! [GPXTrack]
				{
					for segment in track.tracksegments as! [GPXTrackSegment]
					{
						let overlay = segment.overlay
						self.mapView.addOverlay(overlay, level: .AboveLabels)
					}
				}
			}
		}
		
		if let region = trailsLoader.region
		{
			let mapViewRegion = mapView.regionThatFits(region)
			mapView.setRegion(mapViewRegion, animated: true)
		}
	}
}

