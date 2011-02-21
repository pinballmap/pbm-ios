//
//  LocationProfileCell.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationProfileCell.h"


@implementation LocationProfileCell
@synthesize phoneLabel;
@synthesize addressLabel1;
@synthesize addressLabel2;
@synthesize label;
@synthesize distanceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

-(void)setHighlighted:(BOOL)animated
{
	//[super setHighlighted:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   // [super setSelected:NO animated:NO];
}

- (void)dealloc
{	
	[distanceLabel release];
	[phoneLabel release];
	[addressLabel1 release];
	[addressLabel2 release];
	[label release];
	
    [super dealloc];
}


@end
