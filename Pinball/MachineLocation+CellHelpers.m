//
//  MachineLocation+CellHelpers.m
//  PinballMap
//
//  Created by Frank Michael on 6/10/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocation+CellHelpers.h"
#import "NSDate+DateFormatting.h"

@implementation MachineLocation (CellHelpers)

- (NSString *)conditionWithUpdateDate{
    return [NSString stringWithFormat:@"%@ (updated on %@)",self.condition,[self.conditionUpdate monthDayYearPretty:YES]];
}

@end
