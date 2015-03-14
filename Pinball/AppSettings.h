//
//  AppSettings.h
//  PinballMap
//
//  Created by Frank Michael on 3/1/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>

// Settings Key
typedef NS_ENUM(NSInteger, Setting){
    AppSettingCurrentRegion = 0
};

@interface AppSettings : NSObject

+ (NSUserDefaults *)userDefaultsForApp;
+ (id)valueForSetting:(Setting)setting;

@end
