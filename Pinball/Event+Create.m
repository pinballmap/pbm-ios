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

+ (instancetype)createEventWithData:(NSDictionary *)data{
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]];
    newEvent.name = data[@"name"];
    if (![data[@"longDesc"] isKindOfClass:[NSNull class]]){
        newEvent.eventDescription = data[@"longDesc"];
    }else{
        newEvent.eventDescription = @"N/A";
    }
    if (![data[@"link"] isKindOfClass:[NSNull class]]){
        newEvent.link = data[@"link"];
    }else{
        newEvent.link = @"N/A";
    }
    if (![data[@"startDate"] isKindOfClass:[NSNull class]]){
        if ([data[@"startDate"] length] > 0){
            NSDate *date = [NSDate yearMonthDateWithString:data[@"startDate"]];
            newEvent.startDate = date;
        }
    }

    return newEvent;
}

@end
