//
//  GPXBounds.h
//  GPX Framework
//
//  Created by NextBusinessSystem on 12/04/06.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import "GPXElement.h"
#import <CoreLocation/CoreLocation.h>

/** Two lat/lon pairs defining the extent of an element.
 */
@interface GPXBounds : GPXElement


/// ---------------------------------
/// @name Accessing Properties
/// ---------------------------------

/** The minimum latitude. */
@property (nonatomic) CLLocationDegrees minLatitude;

/** The minimum longitude. */
@property (nonatomic) CLLocationDegrees minLongitude;

/** The maximum latitude. */
@property (nonatomic) CLLocationDegrees maxLatitude;

/** The maximum longitude. */
@property (nonatomic) CLLocationDegrees maxLongitude;


/// ---------------------------------
/// @name Create Bounds
/// ---------------------------------

/** Creates and returns a new bounds element.
 @param minLatitude The minimum latitude.
 @param minLongitude The minimum longitude.
 @param maxLatitude The maximum latitude.
 @param maxLongitude The maximum longitude.
 @return A newly created bounds element.
 */
+ (GPXBounds *)boundsWithMinLatitude:(CLLocationDegrees)minLatitude minLongitude:(CLLocationDegrees)minLongitude maxLatitude:(CLLocationDegrees)maxLatitude maxLongitude:(CLLocationDegrees)maxLongitude;

@end
