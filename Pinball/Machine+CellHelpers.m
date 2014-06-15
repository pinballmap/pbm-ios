//
//  Machine+CellHelpers.m
//  PinballMap
//
//  Created by Frank Michael on 4/27/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Machine+CellHelpers.h"

@implementation Machine (CellHelpers)

- (NSAttributedString *)machineTitle{
    NSMutableAttributedString *machineTitle = [[NSMutableAttributedString alloc] initWithString:self.name attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]}];
    [machineTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@, %@)",self.manufacturer,self.year] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}]];
    return machineTitle;
}

@end
