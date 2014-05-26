//
//  UIDevice+ModelCheck.m
//  Pinball
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "UIDevice+ModelCheck.h"

@implementation UIDevice (ModelCheck)

+ (BOOL)iPad{
    if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}

@end
