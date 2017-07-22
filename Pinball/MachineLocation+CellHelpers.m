//
//  MachineLocation+CellHelpers.m
//  PinballMap
//
//  Created by Frank Michael on 6/10/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocation+CellHelpers.h"
#import "NSDate+DateFormatting.h"
#import "MachineCondition.h"

@implementation MachineLocation (CellHelpers)

- (NSString *)formattedConditionDate:(BOOL)addBy conditionUpdate:(NSDate *)conditionUpdate{
    NSString *updatedString = [NSString stringWithFormat:@"Updated on: %@",[conditionUpdate threeLetterMonthPretty]];
    
    if (addBy) {
        updatedString = [NSString stringWithFormat:@"%@ by ", updatedString];
    }
    
    return updatedString;
}

- (NSString *)pastConditionWithUpdateDate:(MachineCondition *)pastCondition {
    BOOL addBy = ([self.updatedByUsername isKindOfClass:[NSNull class]] || [self.updatedByUsername length] == 0) ? NO : YES;

    return [self formattedConditionDate:addBy conditionUpdate:pastCondition.conditionCreated];
}

@end
