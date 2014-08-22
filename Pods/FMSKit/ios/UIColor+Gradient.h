//
//  UIColor+Gradient.h
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIColor (Gradient)
+ (CAGradientLayer *)gradientWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor andBound:(CGRect)bounds;

@end
