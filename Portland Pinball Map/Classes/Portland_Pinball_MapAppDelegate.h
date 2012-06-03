#import <CoreLocation/CoreLocation.h>
#include "RegionObject.h"

#define BASE_URL @"http://glowing-dusk-5085.herokuapp.com"

@class LocationMap;
@class LocationProfileViewController;

@interface Portland_Pinball_MapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSArray *regions; // dict of RegionObjects
	
	RegionObject *activeRegion;
	
	NSMutableDictionary *allLocations; // soon to be depreciated
	NSMutableDictionary *allMachines;  // soon to be depreciated

	UIView *splashScreen;
	CLLocation *userLocation;
	
	LocationProfileViewController *locationProfileView;
	LocationMap *locationMap;
	
	BOOL showUserLocation;
	NSString *rootURL;
}

@property (nonatomic,strong) CLLocation	*userLocation;
@property (nonatomic,strong) NSArray *regions;
@property (nonatomic,strong) RegionObject *activeRegion;
@property (nonatomic,strong) NSString *rootURL;
@property (nonatomic,strong) IBOutlet UIWindow *window;
@property (nonatomic,strong) IBOutlet UINavigationController *navigationController;
@property (nonatomic,strong) NSMutableDictionary *allLocations;
@property (nonatomic,strong) NSMutableDictionary *allMachines;
@property (nonatomic,strong) LocationProfileViewController *locationProfileView;
@property (nonatomic,strong) LocationMap *locationMap;
@property (nonatomic,strong) UIView	*splashScreen;
@property (nonatomic,assign) BOOL showUserLocation;

- (void)showMap:(NSArray *)array withTitle:(NSString *)newTitle;
- (void)newActiveRegion:(RegionObject *)reobj;
- (void)updateLocationDistances;
- (void)hideSplashScreen;
- (void)showSplashScreen;

@end