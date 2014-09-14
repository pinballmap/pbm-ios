//
//  RecentMachine.m
//  PinballMap
//
//  Created by Frank Michael on 9/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "RecentMachine.h"

@implementation RecentMachine

- (instancetype)initWithData:(NSDictionary *)data{
    self = [super init];
    if (self){
        
        // Find Machine info
        NSFetchRequest *machineFetch = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
        machineFetch.predicate = [NSPredicate predicateWithFormat:@"machineId = %@",data[@"machine_id"]];
        machineFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSArray *foundMachines = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:machineFetch error:nil];
        if (foundMachines.count == 1){
            self.machine = [foundMachines firstObject];
        }else{
            self.machine = nil;
        }
        // Find Location info
        NSFetchRequest *locationFetch = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        locationFetch.predicate = [NSPredicate predicateWithFormat:@"locationId = %@",data[@"location_id"]];
        locationFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSArray *foundLocations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:locationFetch error:nil];
        if (foundMachines.count == 1){
            self.location = [foundLocations firstObject];
        }else{
            self.location = nil;
        }
        self.createdOn = data[@"created_at"];
        
    }
    return self;
}

@end
