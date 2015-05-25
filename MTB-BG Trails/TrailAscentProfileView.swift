//
//  TrailAscentProfileView.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/25/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit

class TrailAscentProfileView: UIView
{
    var ascentProfile: [Double]
    
    init(ascentProfile: [Double])
    {
        self.ascentProfile = ascentProfile
        super.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawRect(rect: CGRect)
    {
    }
}
