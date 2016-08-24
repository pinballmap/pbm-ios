//
//  Machine+Create.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Machine+Create.h"

@implementation Machine (Create)

+ (instancetype)createMachineWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    Machine *newMachine = [NSEntityDescription insertNewObjectForEntityForName:@"Machine" inManagedObjectContext:context];
    newMachine.machineId = data[@"id"];
    newMachine.name = data[@"name"];
    if (![data[@"manufacturer"] isKindOfClass:[NSNull class]]){
        newMachine.manufacturer = data[@"manufacturer"];
    }else{
        newMachine.manufacturer = @"N/A";
    }
    if ([data[@"year"] isKindOfClass:[NSNumber class]]){
        newMachine.year = data[@"year"];
    }else{
        newMachine.year = @1963;
    }
    if (![data[@"ipdb_link"] isKindOfClass:[NSNull class]]){
        newMachine.ipdbLink = data[@"ipdb_link"];
    }else{
        newMachine.ipdbLink = @"N/A";
    }
    if ([data[@"machine_group_id"] isKindOfClass:[NSNumber class]]){
        newMachine.machineGroupID = data[@"machine_group_id"];
    }else{
        newMachine.machineGroupID = [NSNumber numberWithInt:-1];
    }
    
    return newMachine;
}

@end
