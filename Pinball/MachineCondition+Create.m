//
//  MachineCondition+Create.m
//  PinballMap
//
//  Created by Frank Michael on 10/21/15.
//  Copyright © 2015 Frank Michael Sanchez. All rights reserved.
//

#import "MachineCondition+Create.h"

@implementation MachineCondition (Create)

+ (instancetype)createMachineConditionWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    MachineCondition *newCondition = [NSEntityDescription insertNewObjectForEntityForName:@"MachineCondition" inManagedObjectContext:context];

    NSString *conditionRaw = [data[@"comment"] isKindOfClass:[NSNull class]] ? @"N/A" : data[@"comment"];
    conditionRaw = [conditionRaw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    newCondition.comment = conditionRaw.length != 0 ? conditionRaw : @"N/A";
    
    if ([newCondition.comment isEqualToString:@"N/A"]){
        return nil;
    }
    
    if (![data[@"created_at"] isKindOfClass:[NSNull class]]){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd"];
        NSString *createdString = data[@"created_at"];
        createdString = [createdString substringToIndex:[createdString rangeOfString:@"T"].location];
        newCondition.conditionCreated = [df dateFromString:createdString];
    }
    newCondition.conditionId = data[@"id"];
    
    return newCondition;
}

@end
