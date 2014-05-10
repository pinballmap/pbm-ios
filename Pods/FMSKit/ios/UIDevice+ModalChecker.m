//
//  UIDevice+ModalChecker.m
//
//  Created by Frank Michael Sanchez on 3/27/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//  https://github.com/fmscode/Objective-C-Categories

#import "UIDevice+ModalChecker.h"

@implementation UIDevice (ModalChecker)
+ (BOOL)isiPad{
    if([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}
+ (BOOL)isiPod{
    if([[UIDevice currentDevice].model rangeOfString:@"iPod"].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}

@end
