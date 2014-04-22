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
    if ([newMachine.name rangeOfString:data[@"manufacturer"] options:NSCaseInsensitiveSearch].location == NSNotFound){
        newMachine.name = [NSString stringWithFormat:@"%@ (%@)",newMachine.name,data[@"manufacturer"]];
    }
    newMachine.manufacturer = data[@"manufacturer"];
    if ([data[@"year"] isKindOfClass:[NSNumber class]]){
        newMachine.year = data[@"year"];
    }else{
        newMachine.year = @1963;
    }
    
    return newMachine;
}

@end
