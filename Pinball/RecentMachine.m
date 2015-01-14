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
        
        NSString *locationName = @"N/A";
        NSString *locationCity = @"N/A";
        if (foundMachines.count == 1){
            self.location = [foundLocations firstObject];
            if (self.location.name != nil){
                locationName = self.location.name;
            }
            if (self.location.city != nil){
                locationCity = self.location.city;
            }
        }else{
            self.location = nil;
        }
        self.createdOn = data[@"created_at"];

        if (self.machine != nil && self.location != nil){
            self.displayText = [[NSMutableAttributedString alloc] initWithString:self.machine.name attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]}];
            [self.displayText appendAttributedString:[[NSAttributedString alloc] initWithString:@" was added to " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}]];
            [self.displayText appendAttributedString:[[NSAttributedString alloc] initWithString:locationName attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]}]];
            [self.displayText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)",locationCity] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}]];
        }else{
            self.displayText = [[NSMutableAttributedString alloc] initWithString:@"N/A" attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]}];
        }
    }
    return self;
}

@end
