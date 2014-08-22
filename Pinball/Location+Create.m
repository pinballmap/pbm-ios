//
//  Location+Create.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location+Create.h"

@implementation Location (Create)

+ (instancetype)createLocationWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    Location *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
    newLocation.locationId = data[@"id"];
    newLocation.name = data[@"name"];
    NSNumberFormatter *stringNumber = [NSNumberFormatter new];
    stringNumber.numberStyle = NSNumberFormatterDecimalStyle;
    
    newLocation.latitude = [stringNumber numberFromString:data[@"lat"]];
    newLocation.longitude = [stringNumber numberFromString:data[@"lon"]];
    newLocation.street = data[@"street"];
    newLocation.city = data[@"city"];
    newLocation.state = data[@"state"];
    newLocation.zip = data[@"zip"];
    if (![data[@"phone"] isKindOfClass:[NSNull class]]){
        if ([data[@"phone"] length] == 0){
            newLocation.phone = @"Tap to edit";
        }else{
            newLocation.phone = data[@"phone"];
        }
    }else{
        newLocation.phone = @"N/A";
    }
    if (![data[@"zone_id"] isKindOfClass:[NSNull class]]){
        newLocation.zoneNo = data[@"zone_id"];
    }else{
        newLocation.zoneNo = @(-1);
    }
    if (![data[@"neighborhood"] isKindOfClass:[NSNull class]]){
        newLocation.neighborhood = data[@"neighborhood"];
    }else{
        newLocation.neighborhood = @"N/A";
    }
    if (![data[@"zone"] isKindOfClass:[NSNull class]]){
        newLocation.locationZone = data[@"zone"];
    }else{
        newLocation.locationZone = @"N/A";
    }
    newLocation.machineCount = @([(NSArray *)data[@"machines"] count]);
    if (![data[@"description"] isKindOfClass:[NSNull class]] && [data[@"description"] length] > 0){
        newLocation.locationDescription = data[@"description"];
    }else{
        newLocation.locationDescription = @"Tap to edit";
    }
    
    if (![data[@"website"] isKindOfClass:[NSNull class]] && [data[@"website"] length] > 0){
        newLocation.website = data[@"website"];
    }else{
        newLocation.website = @"N/A";
    }
    
    
    return newLocation;
}

@end
