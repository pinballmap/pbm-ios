//
//  GAAppHelper.m
//  PinballMap
//
//  Created by Frank Michael on 7/29/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "GAAppHelper.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@implementation GAAppHelper

+ (void)sendAnalyticsDataWithScreen:(NSString *)screenName{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
