//
//  MachineLocation+Create.h
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocation.h"

@interface MachineLocation (Create)

+ (instancetype)createMachineLocationWithData:(NSDictionary *)data;

@end
