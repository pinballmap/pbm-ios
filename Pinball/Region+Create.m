//
//  Region+Create.m
//  Pinball
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
    newRegion.fullName = data[@"fullName"];
    newRegion.latitude = data[@"lat"];
    newRegion.longitude = data[@"lon"];
    return newRegion;
}

@end
