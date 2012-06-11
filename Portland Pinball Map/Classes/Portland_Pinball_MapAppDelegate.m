#import "Portland_Pinball_MapAppDelegate.h"
#import "RootViewController.h"

@implementation Portland_Pinball_MapAppDelegate

@synthesize window, navigationController, locationProfileView, splashScreen, locationMap, showUserLocation, activeRegion, regions, userLocation;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
    regions = [[NSArray alloc] init];
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
	
    if ((activeRegion != nil) && (activeRegion.subdir != nil)) {
        UIImage *regionImage;
		NSString *splashID = [NSString stringWithString:activeRegion.subdir];

        [splashScreen addSubview:base];
        
		if((regionImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_splash.png", splashID]])) {
            UIImageView *region = [[UIImageView alloc] initWithImage:regionImage];
			[region setFrame:CGRectMake(0,20,320,460)];
			[pbm setFrame:CGRectMake(0,20,320,460)];
			
			[splashScreen addSubview:pbm];
			[splashScreen addSubview:region];
			
		} else {
			[pbm setFrame:CGRectMake(0,-10,320,460)];
			[splashScreen addSubview:pbm];
		}		
	} else {
        [splashScreen addSubview:base];
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
		for (Location *key in activeRegion.locations) {
			Location *loc = [activeRegion.locations objectForKey:key];
			[loc updateDistance];
		}
	}	
}

- (NSString *)rootURL {
    return [NSString stringWithFormat:@"%@/%@/iphone.html?", BASE_URL, activeRegion.subdir];
}

- (void)showMap:(NSArray*)array withTitle:(NSString *)newTitle {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end