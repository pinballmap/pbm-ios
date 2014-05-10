//
//  UIDevice+iOSVersion.m
//
//  Created by Frank Michael Sanchez on 3/27/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//  https://github.com/fmscode/Objective-C-Categories

#import "UIDevice+iOSVersion.h"

@implementation UIDevice (iOSVersion)
+ (BOOL)isOS3{
    if ([[UIDevice currentDevice].systemVersion rangeOfString:@"3."].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}
+ (BOOL)isOS4{
    if ([[UIDevice currentDevice].systemVersion rangeOfString:@"4."].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}
+ (BOOL)isOS5{
    if ([[UIDevice currentDevice].systemVersion rangeOfString:@"5."].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}
+ (BOOL)isOS6{
    if ([[UIDevice currentDevice].systemVersion rangeOfString:@"6."].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}
+ (BOOL)isOS7{
    if ([[UIDevice currentDevice].systemVersion rangeOfString:@"7."].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}


@end
