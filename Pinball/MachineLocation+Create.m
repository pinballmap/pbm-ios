//
//  MachineLocation+Create.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocation+Create.h"

@implementation MachineLocation (Create)

+ (instancetype)createMachineLocationWithData:(NSDictionary *)data{
    MachineLocation *newMachine = [NSEntityDescription insertNewObjectForEntityForName:@"MachineLocation" inManagedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]];
    if (![data[@"condition"] isKindOfClass:[NSNull class]]){
        newMachine.condition = data[@"condition"];
    }else{
        newMachine.condition = @"N/A";
    }
    if (![data[@"condition_date"] isKindOfClass:[NSNull class]]){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd"];
        newMachine.conditionUpdate = [df dateFromString:data[@"condition_date"]];
    }else{
        newMachine.conditionUpdate = [NSDate date];
    }
    return newMachine;
}

@end
