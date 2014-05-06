//
//  Machine+Create.m
//  Pinball
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
    
    return newMachine;
}

@end
