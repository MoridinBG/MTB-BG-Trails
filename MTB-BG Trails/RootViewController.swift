//
//  ViewController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit


class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, TrailsLoaderDelegate, TrailsHeaderDelegate
{

	var trails = [Trail]()
	let trailsLoader = TrailsLoader()
	
	@IBOutlet weak var tracksTable: UITableView!
	@IBOutlet weak var tableScrollView: UIScrollView!
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet var mapHeight: NSLayoutConstraint!
	@IBOutlet weak var mapFullHeight: NSLayoutConstraint!
	
	@IBAction func mapClicked(sender: UIButton)
	{
		self.navigationItem.leftBarButtonItem?.enabled = true
		self.navigationItem.leftBarButtonItem?.tintColor = nil
		
		UIView.animateWithDuration(1, animations: {
			self.containerView.bringSubviewToFront(self.mapView)
			self.containerView.removeConstraint(self.mapHeight)
			self.mapView.layoutIfNeeded()
			},
			completion: { (success) in
				self.fitTrailsInMap()
			})
	}
	
	@IBAction func backClicked(sender: UIBarButtonItem)
	{
		self.navigationItem.leftBarButtonItem?.enabled = false
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
		
		UIView.animateWithDuration(1, animations: {
			self.containerView.bringSubviewToFront(self.tableScrollView)
			self.containerView.addConstraint(self.mapHeight)
			self.mapView.layoutIfNeeded()
			},
			completion: { (success) in
				self.fitTrailsInMap()
		})
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		tracksTable.dataSource = self
		mapView.delegate = self
		
		self.navigationItem.leftBarButtonItem?.enabled = false
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
		
		trailsLoader.delegate = self
		trailsLoader.loadTrails(NSURL(string:Constants.Values.vJSONTrailsURL)!) { (trails) in
			self.trails = trails
			println(self.trailsLoader.statistics.date)
			println(self.trailsLoader.statistics.length)
			println(self.trailsLoader.statistics.ascent)
			println(self.trailsLoader.statistics.strenuousness)
			println()
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
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return trails.count
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
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
	{
		let headerCell = tracksTable.dequeueReusableCellWithIdentifier(Constants.Keys.kCellIdTracksHeader) as! TrailsTableHeaderCell
		
		return headerCell
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView)
	{
		if scrollView == tracksTable
		{
			if scrollView.contentOffset.y < 0
			{
				if scrollView.contentOffset.y < -79
				{
					mapClicked(UIButton())
				} else
				{
					mapHeight.constant = scrollView.contentOffset.y
				}
			}
		}
	}
	
	func gpxLoaded(gpx: GPXRoot)
	{
		for track in gpx.tracks as! [GPXTrack]
		{
			for segment in track.tracksegments as! [GPXTrackSegment]
			{
				let overlay = segment.overlay
				self.mapView.addOverlay(overlay, level: .AboveLabels)
			}
		}
		
		self.fitTrailsInMap()
	}
	
	func sortTrails()
	{
	}
	
	func filterTrails()
	{
		
	}
}

