//
//  CoreTableViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CoreTableViewController.h"


@implementation CoreTableViewController

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
