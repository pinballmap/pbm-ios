//
//  UIColor+Gradient.m
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

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
