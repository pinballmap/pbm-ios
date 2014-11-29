//
//  Region+UpdateDistance.m
//  PinballMap
//
//  Created by Frank Michael on 9/7/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Region+UpdateDistance.h"

@implementation Region (UpdateDistance)

- (void)updateDistance{
    CLLocation *currentLocation = [[PinballMapManager sharedInstance] userLocation];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    self.locationDistance = [NSNumber numberWithDouble:([currentLocation distanceFromLocation:location] * 0.00062137)];
}
- (NSNumber *)currentDistance{
    CLLocation *currentLocation = [[PinballMapManager sharedInstance] userLocation];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    return [NSNumber numberWithDouble:([currentLocation distanceFromLocation:location] * 0.00062137)];
}


@end
