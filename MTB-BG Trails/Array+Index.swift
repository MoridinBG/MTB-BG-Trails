//
//  Array+Index.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/20/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

extension Array
{
	func find(includedElement: T -> Bool) -> Int?
	{
		for (idx, element) in enumerate(self)
		{
			if includedElement(element)
			{
				return idx
			}
		}
		return nil
	}
}