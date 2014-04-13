//
//  Region+Create.h
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Region.h"

@interface Region (Create)

+ (instancetype)createRegionWithData:(NSDictionary *)data;

@end
