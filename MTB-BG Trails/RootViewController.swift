//
//  ViewController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit
import MapKit


class RootViewController: MapViewCommon, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, TrailsLoaderDelegate, TrailsFilterDelegate, TrailColorSelectDelegate
{

	// MARK: - Properties
	
	var trails = [Trail]()
	var filteredTrails = [Trail]()
	let trailsLoader = TrailsLoader()
	
	// MARK: - IB Outlets
	
	@IBOutlet weak var trailsTable: UITableView!
	@IBOutlet weak var tableScrollView: UIScrollView!
	@IBOutlet weak var containerView: UIView!
	@IBOutlet var mapHeight: NSLayoutConstraint!
    @IBOutlet weak var mapMaskHeight: NSLayoutConstraint!

	
	private var popoverAnchor = UIButton()
	private var filterPopoverController = TrailsFilterController()
    private var colourPopoverController = TrailColorSelectController()
    private var allTrailOverlays = [MKOverlay]()
	
	// MARK: - IB Actions
	
    @IBAction func filterTrails(sender: UIButton)
    {
        popoverAnchor = sender
        filterPopoverController.modalPresentationStyle = UIModalPresentationStyle.Popover
        filterPopoverController.preferredContentSize = CGSizeMake(500,308)
        filterPopoverController.statistics = trailsLoader.statistics
        filterPopoverController.delegate = self
        
        if let popoverPresentation = filterPopoverController.popoverPresentationController
        {
            popoverPresentation.sourceView = sender
            popoverPresentation.sourceRect = sender.bounds
            popoverPresentation.delegate = self
            self.presentViewController(filterPopoverController, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectTrailColors(sender: UIButton)
    {
        popoverAnchor = sender
        colourPopoverController.modalPresentationStyle = UIModalPresentationStyle.Popover
        colourPopoverController.preferredContentSize = CGSizeMake(203,203)
        colourPopoverController.delegate = self
        
        if let popoverPresentation = colourPopoverController.popoverPresentationController
        {
            popoverPresentation.sourceView = sender
            popoverPresentation.sourceRect = sender.bounds
            popoverPresentation.delegate = self
            self.presentViewController(colourPopoverController, animated: true, completion: nil)
        }
    }
    
    
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
                self.fitTrailsInMap(animated: true)
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
                self.fitTrailsInMap(animated: true)
        })
	}
	
    @IBAction func settingsClicked(sender: UIBarButtonItem)
    {
        let destination = UIStoryboard(name: Constants.Values.vStoryboardSettings, bundle: nil).instantiateInitialViewController() as! UIViewController
        let segue = UIStoryboardSegue(identifier: nil, source: self, destination: destination) {
            self.navigationController?.pushViewController(destination, animated: true)
        }
        
        self.prepareForSegue(segue, sender: self)
        segue.perform()
        
    }
	// MARK: - Lifecycle
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		trailsTable.dataSource = self
        tableScrollView.delegate = self
		mapView.delegate = self
		
        trailsTable.estimatedRowHeight = 89
        trailsTable.rowHeight = UITableViewAutomaticDimension
        
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
				popoverController.sourceRect = popoverAnchor.frame
				popoverController.sourceView = popoverAnchor
			}
		} else if segue.identifier == Constants.Keys.kSegueIdTrailDetails
        {
            let senderCell = sender as! TrailTableCell
            let dest = segue.destinationViewController as! TrailDetailsController
            senderCell.trail.resetColours()
            dest.trail = senderCell.trail
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
        cell.trail = trail
		
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
			cell.dateLabel.text = ""
		}
		
		if let length = trail.length
		{
			cell.lengthLabel.text = "\(length)km"
		} else
		{
			cell.lengthLabel.text = ""
		}
		
		if let ascent = trail.ascent
		{
			cell.ascentLabel.text = "\(ascent)m"
		} else
		{
			cell.ascentLabel.text = ""
		}
		
		if let stren = trail.strenuousness
		{
			cell.strenLabel.text = "\(stren)"
		} else
		{
			cell.strenLabel.text = ""
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
			cell.diffLabel.text = ""
		}
		
		if let duration = trail.duration
		{
			cell.durationLabel.text = duration
            cell.durationLabel.type = .Continuous
            cell.durationLabel.scrollDuration = 30.0
            cell.durationLabel.animationCurve = .Linear
            cell.durationLabel.fadeLength = 0
            cell.durationLabel.leadingBuffer = 30.0
            cell.durationLabel.trailingBuffer = 20.0
		} else
		{
			cell.durationLabel.text = ""
		}
		
		
		return cell
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
                    self.fitTrailsInMap(animated: false)
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
		
		self.fitTrailsInMap(animated: true)
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
	
	private func shouldFilter(	trail: Trail,
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
    
    // MARK: - TrailColorSelectDelegate
    
    func selectedColor(selection: ColorSelection)
    {
        switch selection
        {
            case .Random:
                for trail in trails
                {
                    trail.resetColours()
                }
            
            case .Length:
                let (min, max) = trailsLoader.statistics.length
                let diff = max - min
                
                for trail in trails
                {
                    if let length = trail.length
                    {
                        let factor = CGFloat((max - length) / diff)
                        
                        let colour = UIColor(hue: factor * 0.4, saturation: 1, brightness: 0.9, alpha: 0.9)
                        trail.mainTrack?.colour = colour
                        for track in trail.optionalTracks
                        {
                            track.colour = colour
                        }
                    }
                }
            
            case .Ascent:
                let (min, max) = trailsLoader.statistics.ascent
                let diff = max - min
                
                for trail in trails
                {
                    if let ascent = trail.ascent
                    {
                        let factor = CGFloat((max - ascent) / diff)
                        
                        let colour = UIColor(hue: factor * 0.4, saturation: 1, brightness: 0.9, alpha: 0.9)
                        trail.mainTrack?.colour = colour
                        for track in trail.optionalTracks
                        {
                            track.colour = colour
                        }
                    }
                }
            
            case .Effort:
                let (min, max) = trailsLoader.statistics.strenuousness
                let diff = max - min
                
                for trail in trails
                {
                    if let stren = trail.strenuousness
                    {
                        let factor = CGFloat((max - stren) / diff)
                        
                        let colour = UIColor(hue: factor * 0.4, saturation: 1, brightness: 0.9, alpha: 0.9)
                        trail.mainTrack?.colour = colour
                        for track in trail.optionalTracks
                        {
                            track.colour = colour
                        }
                    }
                }
            case .Technicality:
                let min = Double(trailsLoader.statistics.difficulty.min)
                let max = Double(trailsLoader.statistics.difficulty.max)
                let diff = max - min
                for trail in trails
                {
                    var maxTech = min
                    if let difficulties = trail.difficulty
                    {
                        for diff in difficulties
                        {
                            if Double(diff) > maxTech
                            {
                                maxTech = Double(diff)
                            }
                        }
                    } else
                    {
                        maxTech = diff / 2 //Default to mid difficulty for trails without
                    }
                    
                    let factor = CGFloat((max - maxTech) / diff)
                    
                    let colour = UIColor(hue: factor * 0.4, saturation: 1, brightness: 0.9, alpha: 0.9)
                    trail.mainTrack?.colour = colour
                    for track in trail.optionalTracks
                    {
                        track.colour = colour
                    }
                }
            default: ()
        }
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        mapView.addOverlays(overlays)
    }
    
}

