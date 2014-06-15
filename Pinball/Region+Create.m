//
//  Region+Create.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Region+Create.h"

@implementation Region (Create)

+ (instancetype)createRegionWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    Region *newRegion = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
    newRegion.name = data[@"name"];
    newRegion.fullName = data[@"full_name"];
    
    NSNumberFormatter *stringNumber = [NSNumberFormatter new];
    stringNumber.numberStyle = NSNumberFormatterDecimalStyle;
    
    if ([data[@"lat"] isKindOfClass:[NSString class]]){
        newRegion.latitude = [stringNumber numberFromString:data[@"lat"]];
    }else{
       newRegion.latitude = data[@"lat"];
    }
    if ([data[@"lon"] isKindOfClass:[NSString class]]){
        newRegion.longitude = [stringNumber numberFromString:data[@"lon"]];
    }else{
        newRegion.longitude = data[@"lon"];
    }
    newRegion.regionId = data[@"id"];
    return newRegion;
}

@end
