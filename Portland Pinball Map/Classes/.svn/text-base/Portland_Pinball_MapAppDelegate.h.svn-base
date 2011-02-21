//
//  Portland_Pinball_MapAppDelegate.h
//  Portland Pinball Map
//
//  Created By Isaac Ruiz on 11/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#include <math.h>
#import <CoreLocation/CoreLocation.h>
#include "RegionObject.h"
@class LocationMap;
@class LocationProfileViewController;

@interface Portland_Pinball_MapAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSArray *regions; // dict of RegionObjects
	
	RegionObject *activeRegion;
	
	NSMutableDictionary *allLocations; // soon to be depreciated
	NSMutableDictionary *allMachines;  // soon to be depreciated

	UIView         *splashScreen;
	CLLocation     *userLocation;
	
	LocationProfileViewController *locationProfileView;
	LocationMap                   *locationMap;
	
	BOOL		showUserLocation;
	
	NSString    *rootURL;
}

@property (nonatomic,retain) CLLocation						  *userLocation;
@property (nonatomic,retain) NSArray                          *regions;
@property (nonatomic,retain) RegionObject                     *activeRegion;
@property (nonatomic, retain) NSString  					  *rootURL;
@property (nonatomic, retain) IBOutlet UIWindow				  *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic,retain ) NSMutableDictionary			  *allLocations;
@property (nonatomic,retain ) NSMutableDictionary			  *allMachines;
@property (nonatomic,retain) LocationProfileViewController    *locationProfileView;
@property (nonatomic,retain) LocationMap					  *locationMap;
@property (nonatomic,retain) UIView							  *splashScreen;
@property (nonatomic,assign) BOOL							   showUserLocation;

//+(void) showLocationProfile:(LocationObject*)location;
-(void) showMap:(NSArray*)array withTitle:(NSString *)newTitle;
-(void) newActiveRegion:(RegionObject*)reobj;
-(void) updateLocationDistances;
-(void)hideSplashScreen;
-(void)showSplashScreen;


@end

