//
//  UIApplication+Version.h
//
//  Created by Frank Michael Sanchez on 8/11/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Version)

// Pulls the current version of the application using the info.plist file.
+ (NSString *)version;
// Pulls current version of build of the application using the info.plist file.
+ (NSString *)build;

@end
