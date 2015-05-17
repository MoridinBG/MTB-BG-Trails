//
//  TrailTableCell.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/15/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit

class TrailTableCell: UITableViewCell
{

	@IBOutlet weak var nameLabel: MarqueeLabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var lengthLabel: UILabel!
	@IBOutlet weak var ascentLabel: UILabel!
	@IBOutlet weak var diffLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	
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
