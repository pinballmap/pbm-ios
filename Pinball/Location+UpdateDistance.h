//
//  Location+UpdateDistance.h
//  PinballMap
//
//  Created by Frank Michael on 4/27/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location.h"
#import "Region.h"

@interface Location (UpdateDistance)

- (void)updateDistance;
- (NSNumber *)currentDistance;
+ (void)updateAllForRegion:(Region *)currentRegion;

@end
