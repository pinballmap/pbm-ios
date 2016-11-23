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

- (NSString *)conditionWithUpdateDate{
    NSString * usernameData = @"";
    
    if (![self.updatedByUsername isKindOfClass:[NSNull class]]) {
        usernameData = [NSString stringWithFormat:@" by %@", self.updatedByUsername];
    }
    return [NSString stringWithFormat:@"%@ (updated on %@%@)",self.condition,[self.conditionUpdate monthDayYearPretty:YES], usernameData];
}

- (NSString *)pastConditionWithUpdateDate:(MachineCondition *)pastCondition{
    NSString * usernameData = @"";
    
    if (![pastCondition.createdByUsername isKindOfClass:[NSNull class]]) {
        usernameData = [NSString stringWithFormat:@" by %@", pastCondition.createdByUsername];
    }
    
    if (pastCondition.conditionCreated){
        return [NSString stringWithFormat:@"%@ (updated on %@%@)",pastCondition.comment,[pastCondition.conditionCreated monthDayYearPretty:YES], usernameData];
    }
    
    return [NSString stringWithFormat:@"%@",pastCondition.comment];
    
}

@end
