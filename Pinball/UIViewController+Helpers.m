//
//  UIViewController+Helpers.m
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "UIViewController+Helpers.h"

@implementation UIViewController (Helpers)

- (UIViewController *)detailViewForSplitView{
    return [[(UISplitViewController *)self viewControllers] lastObject];
}
- (UIViewController *)masterViewForSplitView{
    return [[(UISplitViewController *)self viewControllers] firstObject];
}
- (UIViewController *)navigationRootViewController{
    return [[(UINavigationController *)self viewControllers] lastObject];
}
@end
