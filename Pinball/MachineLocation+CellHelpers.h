//
//  MachineLocation+CellHelpers.h
//  PinballMap
//
//  Created by Frank Michael on 6/10/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocation.h"

@interface MachineLocation (CellHelpers)

- (NSString *)formattedConditionDate:(BOOL)addBy conditionUpdate:(NSDate *)conditionUpdate;
- (NSString *)pastConditionWithUpdateDate:(MachineCondition *)pastCondition;

@end
