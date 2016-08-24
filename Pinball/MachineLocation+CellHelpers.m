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
    return [NSString stringWithFormat:@"%@ (updated on %@)",self.condition,[self.conditionUpdate monthDayYearPretty:YES]];
}

- (NSString *)pastConditionWithUpdateDate:(MachineCondition *)pastCondition{
    if (pastCondition.conditionCreated){
        return [NSString stringWithFormat:@"%@ (updated on %@)",pastCondition.comment,[pastCondition.conditionCreated monthDayYearPretty:YES]];
    }
    return [NSString stringWithFormat:@"%@",pastCondition.comment];
    
}

@end
