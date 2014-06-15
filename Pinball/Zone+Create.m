//
//  Zone+Create.m
//  PinballMap
//
//  Created by Frank Michael on 5/25/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Zone+Create.h"

@implementation Zone (Create)

+ (instancetype)createZoneWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    Zone *newZone = [NSEntityDescription insertNewObjectForEntityForName:@"Zone" inManagedObjectContext:context];
    newZone.zoneId = data[@"id"];
    newZone.name = data[@"name"];
    if (![data[@"short_name"] isKindOfClass:[NSNull class]]){
        newZone.shortName = data[@"short_name"];
    }else{
        newZone.shortName = @"";
    }
    
    return newZone;
}

@end
