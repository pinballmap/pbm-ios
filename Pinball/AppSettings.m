//
//  AppSettings.m
//  PinballMap
//
//  Created by Frank Michael on 3/1/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//
//
//  About:
//  App Settings class manages the communication with the user defaults
//      store for app settings

#import "AppSettings.h"

NSString * const appGroupString = @"group.net.isaacruiz.ppm";

@implementation AppSettings

+ (NSUserDefaults *)userDefaultsForApp{
    return [[NSUserDefaults alloc] initWithSuiteName:appGroupString];
}
+ (id)valueForSetting:(Setting)setting{
    NSString *settingKey = [AppSettings keyForSetting:setting];
    return [[AppSettings userDefaultsForApp] objectForKey:settingKey];
}
+ (NSString *)keyForSetting:(Setting)setting{
    switch (setting) {
        case AppSettingCurrentRegion:
            return @"CurrentRegion";
            break;
        default:
            return @"";
            break;
    }
}

@end
