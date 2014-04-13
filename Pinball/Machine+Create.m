//
//  Machine+Create.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Machine+Create.h"

@implementation Machine (Create)

+ (instancetype)createMachineWithData:(NSDictionary *)data{
    Machine *newMachine = [NSEntityDescription insertNewObjectForEntityForName:@"Machine" inManagedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]];
    newMachine.machineId = data[@"id"];
    newMachine.name = data[@"name"];
    newMachine.manufacturer = data[@"manufacturer"];
    newMachine.year = data[@"year"];
    
    return newMachine;
}

@end
