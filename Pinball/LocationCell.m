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
        self.machineCount.layer.cornerRadius = 15;
        self.machineCount.backgroundColor = pinkColor;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code .
    UIColor *pinkColor = [UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1.0];
    
    self.machineCount.layer.cornerRadius = 15;
    self.machineCount.backgroundColor = pinkColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted){
        UIColor *pinkColor = [UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1.0];
        self.machineCount.layer.cornerRadius = 15;
        self.machineCount.backgroundColor = pinkColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected){
        UIColor *pinkColor = [UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1.0];
        self.machineCount.layer.cornerRadius = 15;
        self.machineCount.backgroundColor = pinkColor;
    }
}

- (NSString *)accessibilityLabel{
    NSString *machineText = @"Machines";
    if ([self.machineCount.text isEqualToString:@"1"]){
        machineText = @"Machine";
    }
    return [NSString stringWithFormat:@"%@, %@, %@ %@.",[self.locationName accessibilityLabel],[self.locationDetail accessibilityLabel],[self.machineCount accessibilityLabel],machineText];
}

@end
