//
//  Location+Create.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location+Create.h"

@implementation Location (Create)

+ (instancetype)createLocationWithData:(NSDictionary *)data{
    Location *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]];
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
            newLocation.phone = @"N/A";
        }else{
            newLocation.phone = data[@"phone"];
        }
    }else{
        newLocation.phone = @"N/A";
    }
    if (![data[@"zoneNo"] isKindOfClass:[NSNull class]]){
        newLocation.zoneNo = data[@"zoneNo"];
    }else{
        newLocation.zoneNo = @0;
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
    if (![data[@"numMachines"] isKindOfClass:[NSNull class]]){
        newLocation.machineCount = data[@"numMachines"];
    }else{
        newLocation.machineCount = 0;
    }
    return newLocation;
}

@end
