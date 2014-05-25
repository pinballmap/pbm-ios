//
//  Zone+Create.h
//  Pinball
//
//  Created by Frank Michael on 5/25/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Zone.h"

@interface Zone (Create)

+ (instancetype)createZoneWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context;

@end
