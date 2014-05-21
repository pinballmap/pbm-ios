//
//  LocationType+Create.m
//  Pinball
//
//  Created by Frank Michael on 5/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationType+Create.h"

@implementation LocationType (Create)

+ (instancetype)createLocationTypeWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    LocationType *type = [NSEntityDescription insertNewObjectForEntityForName:@"LocationType" inManagedObjectContext:context];
    type.name = data[@"name"];
    type.locationTypeId = data[@"id"];
    return type;
}

@end
