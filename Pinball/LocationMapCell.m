//
//  LocationMapCell.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationMapCell.h"

@implementation LocationMapCell

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

- (void)addAnnotation{
    UIView *anno = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2, 10, 10)];
    anno.backgroundColor = [UIColor redColor];
    anno.layer.cornerRadius = 5;
    UIImage *image = [UIImage imageNamed:@"pin"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2-image.size.height, image.size.width, image.size.height)];
    imageView.image = image;
    [self addSubview:imageView];    
}

@end
