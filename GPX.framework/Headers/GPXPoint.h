//
//  GPXPoint.h
//  GPX Framework
//
//  Created by NextBusinessSystem on 12/04/06.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import "GPXElement.h"
#import <CoreLocation/CoreLocation.h>


/** A geographic point with optional elevation and time. Available for use by other schemas.
 */
@interface GPXPoint : GPXElement


/// ---------------------------------
/// @name Accessing Properties
/// ---------------------------------

/** The elevation (in meters) of the point. */
@property (nonatomic) CLLocationDistance elevation;

/** The time that the point was recorded. */
@property (strong, nonatomic) NSDate *time;

/** The latitude of the point. Decimal degrees, WGS84 datum */
@property (nonatomic) CLLocationDegrees latitude;

/** The longitude of the point. Decimal degrees, WGS84 datum. */
@property (nonatomic) CLLocationDegrees longitude;


/// ---------------------------------
/// @name Create Point
/// ---------------------------------

/** Creates and returns a new point element.
 @param latitude The latitude of the point.
 @param longitude The longitude of the point.
 @return A newly created point element.
 */
+ (GPXPoint *)pointWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

@end
