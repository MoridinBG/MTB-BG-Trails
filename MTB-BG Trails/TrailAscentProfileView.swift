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
    var track: AttributedTrack?
    {
        didSet
        {
            for point in track!.pointElevations
            {
                if point > maxHeight
                {
                    maxHeight = point
                }
                
                if point < minHeight
                {
                    minHeight = point
                }
            }
            difference = maxHeight - minHeight
        }
    }
    
    var maxHeight = -10000.0
    var minHeight = 10000.0
    var difference = 0.0
    
    override func drawRect(rect: CGRect)
    {
        if let track = track
        {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, UIColor.greenColor().CGColor)
            if track.pointElevations.count > 0
            {
                let start = CGFloat((maxHeight - track.pointElevations[0]) / difference) * rect.height
                let count = track.pointElevations.count
                CGContextMoveToPoint(context, 0, rect.height)
                CGContextAddLineToPoint(context, 0, start)
                for (index, point) in enumerate(track.pointElevations[1..<count])
                {
                    var x = CGFloat(Double(index + 2) / Double(count)) * rect.width //+2 because zero based and we skip actual 0 index ([1..])
                    var y = CGFloat((maxHeight - point) / difference) * rect.height
                    CGContextAddLineToPoint(context, x, y)
                }
            }
            CGContextAddLineToPoint(context, rect.width, rect.height)
            CGContextClosePath(context)
            CGContextFillPath(context)
        }
    }
}
