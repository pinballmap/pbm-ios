//
//  UIColor+Gradient.m
//
//  Created by Frank Michael Sanchez on 3/27/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//  https://github.com/fmscode/Objective-C-Categories
//  Inspired by: http://danielbeard.wordpress.com/2012/02/25/gradient-background-for-uiview-in-ios/

#import "UIColor+Gradient.h"

@implementation UIColor (Gradient)
+ (CAGradientLayer *)gradientWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor andBound:(CGRect)bounds{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)topColor.CGColor,(id)bottomColor.CGColor];
    gradient.locations = @[@0,@1];
    gradient.frame = bounds;
    return gradient;
}
@end
