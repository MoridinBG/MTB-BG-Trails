//
//  NSDate+Compare.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/18/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

public func < (left : NSDate, right : NSDate) -> Bool
{
	return left.compare(right) == NSComparisonResult.OrderedAscending
}

public func > (left : NSDate, right : NSDate) -> Bool
{
	return left.compare(right) == NSComparisonResult.OrderedDescending
}

public func == (left : NSDate, right : NSDate) -> Bool
{
	return left.isEqualToDate(right)
}

extension NSDate : Comparable {}