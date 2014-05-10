//
//  UIColor+Gradient.h
//
//  Created by Frank Michael Sanchez on 3/27/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//  https://github.com/fmscode/Objective-C-Categories
//  Inspired by: http://danielbeard.wordpress.com/2012/02/25/gradient-background-for-uiview-in-ios/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIColor (Gradient)
+ (CAGradientLayer *)gradientWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor andBound:(CGRect)bounds;

@end
