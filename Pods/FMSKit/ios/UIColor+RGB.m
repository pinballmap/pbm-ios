//
//  UIColor+RGB.m
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor (RGB)

+ (UIColor *)colorUsingRed:(CGFloat)red green:(CGFloat)green andBlue:(CGFloat)blue{
    UIColor *color = [UIColor colorWithRed:(red/255) green:(green/255) blue:(blue/255) alpha:1];
    return color;
}

@end
