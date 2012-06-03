#import "Portland_Pinball_MapAppDelegate.h"
#import "RootViewController.h"

@implementation Portland_Pinball_MapAppDelegate

@synthesize window, navigationController, locationProfileView, splashScreen, locationMap, showUserLocation, activeRegion, regions, userLocation;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	userLocation = [[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785];
	
	navigationController.navigationBar.barStyle = UIBarStyleBlack;	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
		
	[self showSplashScreen];
}

- (void)showSplashScreen {
	[self hideSplashScreen];
	
	splashScreen = [[UIView alloc] init];
	[splashScreen setUserInteractionEnabled:NO];
	
	UIImageView *pbm = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pbm2.png"]];
	UIImageView *base = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"base_blank.png"]];
	[base setFrame:CGRectMake(0,20,320,460)];
	
	if(activeRegion == nil) {
		[splashScreen addSubview:base];
	} else {		
		NSString *splash_id = [NSString stringWithString:activeRegion.subdir];
		NSString *imageName = [NSString stringWithFormat:@"%@_splash.png",splash_id];
		UIImageView *region = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
		
		NSArray *availableRegions = [[NSArray alloc] initWithObjects:@"",@"albuquerque",@"austin",@"bayarea",@"bc",@"boston", @"chicago",@"detroit",@"la", @"lasvegas",@"toronto",@"newyork", @"sandiego",@"seattle",nil];
		
		if([availableRegions containsObject:splash_id]) {
			[region setFrame:CGRectMake(0,20,320,460)];
			[pbm setFrame:CGRectMake(0,20,320,460)];
			
			[splashScreen addSubview:base];
			[splashScreen addSubview:pbm];
			[splashScreen addSubview:region];
			
		} else {
			[pbm setFrame:CGRectMake(0,-10,320,460)];
			[splashScreen addSubview:base];
			[splashScreen addSubview:pbm];
		}
		
	}

	[window addSubview:splashScreen];
}

- (void)hideSplashScreen {
	if(splashScreen != nil) {
		if(splashScreen.superview != nil)
			[splashScreen removeFromSuperview];
		
		splashScreen = nil;
	}
}

- (void)updateLocationDistances {
	if([activeRegion.locations count] > 0) {
		for (id key in activeRegion.locations) {
			LocationObject *loc = [activeRegion.locations objectForKey:key];
			[loc updateDistance];
		}
	}	
}

- (NSString *)rootURL {
    return [NSString stringWithFormat:@"%@%@/iphone.html?", BASE_URL, activeRegion.subdir];
}

- (void)showMap:(NSArray*)array withTitle:(NSString *)newTitle {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end