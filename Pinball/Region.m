//
//  Region.m
//  PinballMap
//
//  Created by Frank Michael on 9/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Region.h"
#import "Event.h"
#import "Location.h"
#import "Zone.h"

@implementation Region

@dynamic eventsEtag, fullName, latitude, locationDistance, locationsEtag, longitude, name, regionId, zonesEtag, events, locations, zones, operators, operatorsEtag;

- (NSMutableArray *)machineLocations {
    NSMutableArray *machineLocations = [[NSMutableArray alloc] init];
    for (Location *location in self.locations) {
        [machineLocations addObjectsFromArray:[location.machines allObjects]];
    }
    
    return machineLocations;
}

@end
