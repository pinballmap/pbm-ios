//
//  InformationCell.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "InformationCell.h"

@implementation InformationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
