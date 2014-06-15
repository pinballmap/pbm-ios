//
//  LocationType+Create.h
//  PinballMap
//
//  Created by Frank Michael on 5/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationType.h"

@interface LocationType (Create)

+ (instancetype)createLocationTypeWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context;

@end
