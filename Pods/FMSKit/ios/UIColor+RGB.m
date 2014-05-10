//
//  UIColor+RGB.m
//
//  Created by Frank Michael Sanchez on 3/27/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//  https://github.com/fmscode/Objective-C-Categories

#import "UIColor+RGB.h"

@implementation UIColor (RGB)
+ (UIColor *)colorUsingRed:(CGFloat)red green:(CGFloat)green andBlue:(CGFloat)blue{
    UIColor *color = [UIColor colorWithRed:(red/255) green:(green/255) blue:(blue/255) alpha:1];
    return color;
}
@end
