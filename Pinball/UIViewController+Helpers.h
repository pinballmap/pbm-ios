//
//  UIViewController+Helpers.h
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Helpers)

- (UIViewController *)detailViewForSplitView;
- (UIViewController *)masterViewForSplitView;

- (UIViewController *)navigationRootViewController;

@end
