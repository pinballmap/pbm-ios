//
//  Event+Create.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Event+Create.h"
#import "NSDate+DateFormatting.h"

@implementation Event (Create)

+ (instancetype)createEventWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
    newEvent.name = data[@"name"];
    newEvent.eventId = data[@"id"];
    
    if (![data[@"long_desc"] isKindOfClass:[NSNull class]]){
        newEvent.eventDescription = data[@"long_desc"];
    }else{
        newEvent.eventDescription = @"N/A";
    }
    if (![data[@"external_link"] isKindOfClass:[NSNull class]]){
        newEvent.link = data[@"external_link"];
    }else{
        newEvent.link = @"N/A";
    }
    if (![data[@"start_date"] isKindOfClass:[NSNull class]]){
        if ([data[@"start_date"] length] > 0){
            NSDate *date = [NSDate yearMonthDateWithString:data[@"start_date"]];
            newEvent.startDate = date;
        }
    }
    if (![data[@"end_date"] isKindOfClass:[NSNull class]]){
        if ([data[@"end_date"] length] > 0){
            newEvent.endDate = [NSDate yearMonthDateWithString:data[@"end_date"]];
        }
    }
    if (![data[@"external_location_name"] isKindOfClass:[NSNull class]]){
        newEvent.externalLocationName = data[@"external_location_name"];
    }
    if (![data[@"category"] isKindOfClass:[NSNull class]]){
        newEvent.categoryTitle = data[@"category"];
    }
    
    return newEvent;
}

@end
