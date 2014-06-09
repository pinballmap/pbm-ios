//
//  UIApplication+Version.m
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "UIApplication+Version.h"

@implementation UIApplication (Version)
+ (NSString *)version{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+ (NSString *)build{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}
@end
