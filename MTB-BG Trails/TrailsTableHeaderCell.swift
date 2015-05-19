//
//  TrailsTableHeaderCell.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/18/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit

protocol TrailsHeaderDelegate
{
	func filterTrails(sender: UIButton)
	func sortTrails(sender: UIButton)
}

class TrailsTableHeaderCell: UITableViewCell
{
	var delegate: TrailsHeaderDelegate?
	
	@IBAction func filter(sender: UIButton)
	{
		delegate?.filterTrails(sender)
	}
	
	@IBAction func sort(sender: UIButton)
	{
		delegate?.sortTrails(sender)
	}
	
    override func awakeFromNib()
	{
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
	{
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
