//
//  Region+Extensions.m
//  PinballMap
//
//  Created by Frank Michael on 12/28/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Region+Extensions.h"

@implementation Region (Extensions)

- (NSUInteger)numberOfLocations{
    NSFetchRequest *locationsCountFetch = [[NSFetchRequest alloc] initWithEntityName:@"Location"];
    locationsCountFetch.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",self.name];
    locationsCountFetch.includesSubentities = false;
    
    NSError *error;
    NSUInteger count = [[[CoreDataManager sharedInstance] managedObjectContext] countForFetchRequest:locationsCountFetch error:&error];
    if (error != nil || count == NSNotFound){
        return 0;
    }
    return count;
}
- (NSUInteger)numberOfLocalMachines{
    NSFetchRequest *machinesCountFetch = [[NSFetchRequest alloc] initWithEntityName:@"Machine"];
    machinesCountFetch.predicate = [NSPredicate predicateWithFormat:@"machineLocations.location.region CONTAINS %@",self];
    machinesCountFetch.includesSubentities = false;
    
    NSError *error;
    NSUInteger count = [[[CoreDataManager sharedInstance] managedObjectContext] countForFetchRequest:machinesCountFetch error:&error];
    if (error != nil || count == NSNotFound){
        return 0;
    }
    return count;
}

@end
