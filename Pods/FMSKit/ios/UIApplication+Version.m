//
//  UIApplication+Version.m
//
//  Created by Frank Michael Sanchez on 8/11/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
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
