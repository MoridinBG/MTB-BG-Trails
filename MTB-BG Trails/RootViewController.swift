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
	
	private var filterPopoverAnchor = UIButton()
	private var filterPopoverController = TrailsFilterController()
    private var allTrailOverlays = [MKOverlay]()
	
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
		} else if segue.identifier == Constants.Keys.kSegueIdTrailDetails
        {
            let dest = segue.destinationViewController as! TrailDetailsController
            dest.trail = trails[trailsTable.indexPathForSelectedRow()!.row]
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
				cell.diffLabel.text! += Constants.Values.vTrailDifficultyClasses[diff] + " "
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
	
	func loadGPXTracks(tracks: [AttributedTrack])
	{
		for track in tracks
		{
			self.mapView.addOverlay(track.trackPolyline, level: .AboveLabels)
            allTrailOverlays.append(track.trackPolyline)
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
	
	func applyFilters(filters: [TrailFilter])
	{
		filteredTrails.removeAll(keepCapacity: false)
		for trail in trails
		{
            var filtered = false
			for filter in filters
			{
                if filtered
                {
                    break
                }
                
				switch filter
				{
					case .lengthFilter(let minLength, let maxLength):
						if shouldFilter(trail,
											filteredValue: trail.length,
											minLimit: Double(minLength),
											absoluteMinLimit: trailsLoader.statistics.length.min,
											maxLimit: Double(maxLength),
											absoluteMaxLimit: trailsLoader.statistics.length.max,
											filtersNil: false)
                        {
                            filtered = true
                        }
					
					case .ascentFilter(let minAscent, let maxAscent):
						if shouldFilter(trail,
                                            filteredValue: trail.ascent,
                                            minLimit: Double(minAscent),
                                            absoluteMinLimit: trailsLoader.statistics.ascent.min,
                                            maxLimit: Double(maxAscent),
                                            absoluteMaxLimit: trailsLoader.statistics.ascent.max,
                                            filtersNil: false)
                        {
                            filtered = true
                        }
                    
					case .effortFilter(let minEffort, let maxEffort):
						if shouldFilter(trail,
                                            filteredValue: trail.strenuousness,
                                            minLimit: Double(minEffort),
                                            absoluteMinLimit: trailsLoader.statistics.strenuousness.min,
                                            maxLimit: Double(maxEffort),
                                            absoluteMaxLimit: trailsLoader.statistics.strenuousness.max,
                                            filtersNil: true)
                        {
                            filtered = true
                        }
                    
					case .diffFilter(let minDiff, let maxDiff):
						if let difficulties = trail.difficulty
						{
							for difficulty in difficulties
							{
                                if filtered
                                {
                                    break
                                }
                                let optionalDiff: Double? = Double(difficulty)
								if shouldFilter(trail,
									filteredValue: optionalDiff,
									minLimit: Double(minDiff),
									absoluteMinLimit: Double(trailsLoader.statistics.difficulty.min),
									maxLimit: Double(maxDiff),
									absoluteMaxLimit: Double(trailsLoader.statistics.difficulty.max),
									filtersNil: true)
								{
									filtered = true
								}
							}
						} else
                        {
                            if shouldFilter(trail,
                                filteredValue: nil,
                                minLimit: Double(minDiff),
                                absoluteMinLimit: Double(trailsLoader.statistics.difficulty.min),
                                maxLimit: Double(maxDiff),
                                absoluteMaxLimit: Double(trailsLoader.statistics.difficulty.max),
                                filtersNil: true)
                            {
                                filtered = true
                            }
                        }
				}
			}
            
            if !filtered
            {
                if !trail.overlaysShown
                {
                    trail.overlaysShown = true
                    for track in trail.gpsTracks()
                    {
                        mapView.addOverlay(track.trackPolyline)
                    }
                }
                
                filteredTrails.append(trail)
            } else
            {
                if trail.overlaysShown
                {
                    trail.overlaysShown = false
                    for track in trail.gpsTracks()
                    {
                        mapView.removeOverlay(track.trackPolyline)
                    }
                }
            }
		}
		
		trailsTable.reloadData()
	}
	
	func shouldFilter(	trail: Trail,
						filteredValue: Double?,
						minLimit: Double,
						absoluteMinLimit: Double,
						maxLimit: Double,
						absoluteMaxLimit: Double,
						filtersNil: Bool) -> Bool
	{
		if let value = filteredValue
		{
			if value < minLimit || value > maxLimit
			{
				return true
			}
		} else if filtersNil && absoluteMinLimit <= minLimit
		{
			return true
		}

		return false
	}
}

