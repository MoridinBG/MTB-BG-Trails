//
//  ViewController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit


class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, TrailsLoaderDelegate, TrailsHeaderDelegate, TrailsFilterDelegate
{

	// MARK: - Properties
	
	var trails = [Trail]()
	var filteredTrails = [Trail]()
	let trailsLoader = TrailsLoader()
	
	// MARK: - IB Outlets
	
	@IBOutlet weak var trailsTable: UITableView!
	@IBOutlet weak var tableScrollView: UIScrollView!
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet var mapHeight: NSLayoutConstraint!
	@IBOutlet weak var mapFullHeight: NSLayoutConstraint!
	
	private var filterPopoverAnchor = UIButton()
	private var filterPopoverController = TrailsFilterController()
	
	// MARK: - IB Actions
	
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
	
	// MARK: - Lifecycle
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		trailsTable.dataSource = self
		mapView.delegate = self
		
		self.navigationItem.leftBarButtonItem?.enabled = false
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
		
		trailsLoader.delegate = self
		trailsLoader.loadTrails(NSURL(string:Constants.Values.vJSONTrailsURL)!) { (trails) in
			self.trails = trails
			self.filteredTrails = trails

			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.trailsTable.reloadData()
			})
		}
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if segue.identifier == Constants.Keys.kSegueIdTracksFilterPopover
		{
			let controller = segue.destinationViewController as! UIViewController
			let popoverController2 = controller.popoverPresentationController
			if let popoverController = popoverController2
			{
				println("Here")
				popoverController.delegate = self
				popoverController.sourceRect = filterPopoverAnchor.frame
				popoverController.sourceView = filterPopoverAnchor
			}
		}
	}
	
	// MARK: - UITableViewDelegate & DataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return filteredTrails.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = trailsTable.dequeueReusableCellWithIdentifier(Constants.Keys.kCellIdTracks) as! TrailTableCell
		var trail = filteredTrails[indexPath.row]
		
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
		
		if let stren = trail.strenuousness
		{
			cell.strenLabel.text = "\(stren)"
		} else
		{
			cell.strenLabel.text = "n/a"
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
		let headerCell = trailsTable.dequeueReusableCellWithIdentifier(Constants.Keys.kCellIdTracksHeader) as! TrailsTableHeaderCell
		headerCell.delegate = self
		
		return headerCell
	}
	
	// MARK: - UIScrollViewDelegate
	
	func scrollViewDidScroll(scrollView: UIScrollView)
	{
		if scrollView == trailsTable
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
	
	// MARK: - UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
	{
		return .None
	}
	
	// MARK: - TrailsLoaderDelegate
	
	func loadGPXOverlays(overlays: [MKOverlay])
	{
		for overlay in overlays
		{
			self.mapView.addOverlay(overlay, level: .AboveLabels)
		}
		
		self.fitTrailsInMap()
	}
	
	// MARK: - TrailsHeaderDelegate
	
	func sortTrails(sender: UIButton)
	{
		
	}
	
	func filterTrails(sender: UIButton)
	{
		filterPopoverAnchor = sender
		filterPopoverController.modalPresentationStyle = UIModalPresentationStyle.Popover
		filterPopoverController.preferredContentSize = CGSizeMake(500,308)
		filterPopoverController.statistics = trailsLoader.statistics
		filterPopoverController.delegate = self
		
		if let popoverPresentation = filterPopoverController.popoverPresentationController
		{
			popoverPresentation.sourceView = sender
			popoverPresentation.sourceRect = sender.frame
			popoverPresentation.delegate = self
			self.presentViewController(filterPopoverController, animated: true, completion: nil)
		}
	}
	
	// MARK: - TrailsFilterDelegate
	// TODO: Simplify & reduce redundancy
	
	func lengthChanged(min: Float, max: Float)
	{
		filteredTrails.removeAll(keepCapacity: false)
		for trail in trails
		{
			if let length = trail.length
			{
				if length > Double(max) || length < Double(min)
				{
					if trail.overlaysShown
					{
						if let overlays = trail.gpxOverlays
						{
							trail.overlaysShown = false
							for overlay in overlays
							{
								mapView.removeOverlay(overlay)
							}
						}
					}
					continue
				}
			}
			
			filteredTrails.append(trail)
			if !trail.overlaysShown
			{
				if let overlays = trail.gpxOverlays
				{
					trail.overlaysShown = true
					for overlay in overlays
					{
						mapView.addOverlay(overlay)
					}
				}
			}
		}
		
		trailsTable.reloadData()
	}
	
	func ascentChanged(min: Float, max: Float)
	{
		filteredTrails.removeAll(keepCapacity: false)
		for trail in trails
		{
			if let ascent = trail.ascent
			{
				if ascent > Double(max) || ascent < Double(min)
				{
					if trail.overlaysShown
					{
						if let overlays = trail.gpxOverlays
						{
							trail.overlaysShown = false
							for overlay in overlays
							{
								mapView.removeOverlay(overlay)
							}
						}
					}
					continue
				}
			}
			
			filteredTrails.append(trail)
			if !trail.overlaysShown
			{
				if let overlays = trail.gpxOverlays
				{
					trail.overlaysShown = true
					for overlay in overlays
					{
						mapView.addOverlay(overlay)
					}
				}
			}
		}
		
		trailsTable.reloadData()
	}
	
	func effortChanged(min: Float, max: Float)
	{
		filteredTrails.removeAll(keepCapacity: false)
		for trail in trails
		{
			if let strenuousness = trail.strenuousness
			{
				if strenuousness > Double(max) || strenuousness < Double(min)
				{
					if trail.overlaysShown
					{
						if let overlays = trail.gpxOverlays
						{
							trail.overlaysShown = false
							for overlay in overlays
							{
								mapView.removeOverlay(overlay)
							}
						}
					}
					continue
				}
			} else if trailsLoader.statistics.strenuousness.min < Double(min)
			{
				if trail.overlaysShown
				{
					if let overlays = trail.gpxOverlays
					{
						trail.overlaysShown = false
						for overlay in overlays
						{
							mapView.removeOverlay(overlay)
						}
					}
				}
				continue
			}
			
			filteredTrails.append(trail)
			if !trail.overlaysShown
			{
				if let overlays = trail.gpxOverlays
				{
					trail.overlaysShown = true
					for overlay in overlays
					{
						mapView.addOverlay(overlay)
					}
				}
			}
		}
		
		trailsTable.reloadData()
	}
}

