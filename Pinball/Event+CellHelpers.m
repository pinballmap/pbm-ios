//
//  Event+CellHelpers.m
//  Pinball
//
//  Created by Frank Michael on 6/6/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Event+CellHelpers.h"

@implementation Event (CellHelpers)

- (NSAttributedString *)eventTitle{
    NSMutableAttributedString *eventTitle = [[NSMutableAttributedString alloc] initWithString:self.name attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]}];
    if ([self.name rangeOfString:@"N/A"].location == NSNotFound){
        [eventTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)",self.categoryTitle] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}]];
    }
    return eventTitle;
}

@end
