#import <CoreLocation/CoreLocation.h>
#import "RegionObject.h"
#import "LocationMap.h"

#define BASE_URL @"http://glowing-dusk-5085.herokuapp.com"

@class LocationProfileViewController;

@interface Portland_Pinball_MapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSArray *regions;
	RegionObject *activeRegion;

	UIView *splashScreen;
	CLLocation *userLocation;
	
	LocationProfileViewController *locationProfileView;
	LocationMap *locationMap;
	
	BOOL showUserLocation;
}

@property (nonatomic,strong) CLLocation	*userLocation;
@property (nonatomic,strong) NSArray *regions;
@property (nonatomic,strong) RegionObject *activeRegion;
@property (nonatomic,strong) IBOutlet UIWindow *window;
@property (nonatomic,strong) IBOutlet UINavigationController *navigationController;
@property (nonatomic,strong) LocationProfileViewController *locationProfileView;
@property (nonatomic,strong) LocationMap *locationMap;
@property (nonatomic,strong) UIView	*splashScreen;
@property (nonatomic,assign) BOOL showUserLocation;

- (void)showMap:(NSArray *)array withTitle:(NSString *)newTitle;
- (void)updateLocationDistances;
- (void)hideSplashScreen;
- (void)showSplashScreen;
- (NSString *)rootURL;

@end