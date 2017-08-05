//
//  MachineLocation+Create.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocation+Create.h"
#import "MachineCondition+Create.h"

@implementation MachineLocation (Create)

+ (instancetype)createMachineLocationWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    MachineLocation *newMachineLocation = [NSEntityDescription insertNewObjectForEntityForName:@"MachineLocation" inManagedObjectContext:context];
    newMachineLocation.machineLocationId = data[@"id"];
    if (![data[@"condition"] isKindOfClass:[NSNull class]]){
        newMachineLocation.condition = data[@"condition"];
    }else{
        newMachineLocation.condition = @"N/A";
    }
    
    NSArray *conditions = [data[@"machine_conditions"] isKindOfClass:[NSNull class]] ? @[] : data[@"machine_conditions"];
    
    if (conditions.count > 0){
        for (NSDictionary *condition in conditions) {
            MachineCondition *machineCondition = [MachineCondition createMachineConditionWithData:condition andContext:context];
            if (machineCondition != nil){
                machineCondition.machineLocation = newMachineLocation;
                [newMachineLocation addConditionsObject:machineCondition];
            }
            machineCondition = nil;
        }
    }
    
    if (![data[@"condition_date"] isKindOfClass:[NSNull class]]){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd"];
        newMachineLocation.conditionUpdate = [df dateFromString:data[@"condition_date"]];
    }else{
        newMachineLocation.conditionUpdate = [NSDate date];
    }
    
    if (![data[@"last_updated_by_username"] isKindOfClass:[NSNull class]]) {
        newMachineLocation.updatedByUsername = data[@"last_updated_by_username"];
    }
    
    return newMachineLocation;
}

@end
