//
//  LocationCell.m
//  PinballMap
//
//  Created by Frank Michael on 6/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIColor *pinkColor = [UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1.0];

        _machineCount.layer.cornerRadius = 15;
        _machineCount.backgroundColor = pinkColor;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    UIColor *pinkColor = [UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1.0];
    
    _machineCount.layer.cornerRadius = 15;
    _machineCount.backgroundColor = pinkColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
