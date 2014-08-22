//
//  Location+Create.h
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location.h"

@interface Location (Create)

+ (instancetype)createLocationWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context;

@end
