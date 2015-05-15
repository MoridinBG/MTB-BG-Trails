//
//  ViewController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/11/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit


class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate
{

	private var trails = [Trail]()
	private let trailsLoader = TrailsLoader()
	
	@IBOutlet weak var tracksTable: UITableView!
	@IBOutlet weak var tableScrollView: UIScrollView!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		tracksTable.dataSource = self
		tableScrollView.delegate = self
		
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
		let cell = tracksTable.dequeueReusableCellWithIdentifier(Constants.Keys.kCellIdTracks) as! UITableViewCell
		
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
}

