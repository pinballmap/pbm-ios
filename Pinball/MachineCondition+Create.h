//
//  MachineCondition+Create.h
//  PinballMap
//
//  Created by Frank Michael on 10/21/15.
//  Copyright © 2015 Frank Michael Sanchez. All rights reserved.
//

#import "MachineCondition.h"

@interface MachineCondition (Create)

+ (instancetype)createMachineConditionWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context;

@end
