//
//  PinballManager.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "PinballManager.h"

@implementation PinballManager

+ (id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p,^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)importFromJSON{
    NSData *jsonFile = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pinball_data" ofType:@"json"]];
    NSDictionary *pinballData = [NSJSONSerialization JSONObjectWithData:jsonFile options:NSJSONReadingAllowFragments error:nil][@"data"][@"region"];
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    [cdManager resetStore];
    
    _currentRegion = [Region createRegionWithData:pinballData];
    // Create all machines.
    // Save the machines to a array to be used when creating the MachineLocation objects to ref.
    NSMutableSet *machines = [NSMutableSet new];
    [pinballData[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *machineData = obj[@"machine"];
        Machine *newMachine = [Machine createMachineWithData:machineData];
        [machines addObject:newMachine];
    }];
    [cdManager saveContext];
    // Add machines to region object.
    [_currentRegion addMachines:machines];
    // Create all locations
    [pinballData[@"locations"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *location = obj[@"location"];
        Location *newLocation = [Location createLocationWithData:location];
        [location[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *machineLocation = obj[@"machine"];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"machineId = %@" argumentArray:@[machineLocation[@"id"]]];
            NSSet *found = [machines filteredSetUsingPredicate:pred];
            
            MachineLocation *locMachine = [MachineLocation createMachineLocationWithData:machineLocation];
            locMachine.machine = [found anyObject];
            locMachine.location = newLocation;
            [newLocation addMachinesObject:locMachine];
        }];
        [_currentRegion addLocationsObject:newLocation];
    }];
    [cdManager saveContext];
}

@end
