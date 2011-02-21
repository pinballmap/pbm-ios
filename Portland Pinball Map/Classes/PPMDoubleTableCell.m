//
//  DoubleTextViewCell.m
//  Portland Pinball Map
//
//  Created By Isaac Ruiz on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPMDoubleTableCell.h"


@implementation PPMDoubleTableCell
@synthesize subLabel;

- (void)dealloc {
	[subLabel release];
    [super dealloc];
}


@end
