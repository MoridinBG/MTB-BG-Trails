//
//  GPXTrackPointExtensions.h
//  GPX
//
//  Created by Felix Schneider on 29.09.2014.
//
//

#import "GPXElement.h"

@interface GPXTrackPointExtensions : GPXElement

/* see: http://www8.garmin.com/xmlschemas/TrackPointExtensionv2.xsd */
@property (nonatomic, strong) NSNumber *heartRate;
@property (nonatomic, strong) NSNumber *cadence;
@property (nonatomic, strong) NSNumber *speed;
@property (nonatomic, strong) NSNumber *course;

@end
