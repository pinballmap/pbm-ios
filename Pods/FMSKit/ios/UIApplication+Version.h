//
//  UIApplication+Version.h
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Version)

// Current version of the application from info.plist
+ (NSString *)version;
// Current build number of the application from info.plist
+ (NSString *)build;

@end
