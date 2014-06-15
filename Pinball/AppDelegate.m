//
//  AppDelegate.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "AppDelegate.h"
#import "PinballMapManager.h"
#import <HockeySDK/HockeySDK.h>
#import "LocationProfileView-iPad.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIColor *pinkColor = [UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1.0];
    [[UITabBar appearance] setTintColor:pinkColor];
    [[UISearchBar appearance] setTintColor:pinkColor];
    [[UINavigationBar appearance] setTintColor:pinkColor];
    [[UIToolbar appearance] setTintColor:pinkColor];

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"9df362e5aa49991c0c332aefdcdfdcd7"];
    [[BITHockeyManager sharedHockeyManager].authenticator setAuthenticationSecret:@"40e42e27b4656b3ff6a7c380a5433cc0"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([UIDevice iPad]){
        LocationProfileView_iPad *locations = (LocationProfileView_iPad *)[[[(UITabBarController *)self.window.rootViewController viewControllers] firstObject] navigationRootViewController];
        [locations showListingsView:nil];
    }

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
