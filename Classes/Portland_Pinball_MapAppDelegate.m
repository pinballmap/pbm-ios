#import "Portland_Pinball_MapAppDelegate.h"

#import "SplashViewController.h"
#import "LocationMap.h"
#import "ZonesViewController.h"
#import "RequestPage.h"
#import "LocationMachineXref.h"
#import "Utils.h"
#import "APIManager.h"



@implementation Portland_Pinball_MapAppDelegate

@synthesize window, navigationController, splitViewController, splashScreen, locationMap, showUserLocation, activeRegion, userLocation, internetActive, locationManager;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}


- (bool)isPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"b0b7ff36-b459-483b-8c44-57b51e53cfae"];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
    userLocation      = [[CLLocation alloc] initWithLatitude:PDX_LAT longitude:PDX_LON];
    
    initLoaded = NO;
    
    NSLog(@"BASE URL: %@", BASE_URL);
    
    internetReachable_ = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    [internetReachable_ startNotifier];
    [self checkNetworkStatus:nil];
    
    //Load Windows
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        SplashViewController *masterViewController = [[SplashViewController alloc] initWithNibName:@"SplashView" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        self.window.rootViewController = self.navigationController;
        masterViewController.managedObjectContext = self.managedObjectContext;
    } else {
        SplashViewController *masterViewController = [[SplashViewController alloc] initWithNibName:@"SplashView" bundle:nil];
        masterViewController.managedObjectContext = self.managedObjectContext;

        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        
        LocationMap *detailViewController = [[LocationMap alloc] init];
        
        //UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    	//masterViewController.detailViewController = detailViewController;
        
        self.splitViewController = [[UISplitViewController alloc] init];
        //self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = @[masterNavigationController, detailViewController];
        
        self.window.rootViewController = self.splitViewController;
        self.locationMap = detailViewController;
        detailViewController = nil;
        //masterViewController.managedObjectContext = self.managedObjectContext;
    }
    [self.window makeKeyAndVisible];
    
    activeRegion = (Region *)[self fetchObject:@"Region" where:@"idNumber" equals:(NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"activeRegionID"]];
    
    NSLog(@"SAVED REGION NAME %@", activeRegion.name);
    
	if (internetActive) {
        NSLog(@"INTERNET ACTIVE, RESETTING DATABASE");
        [self resetDatabase];
        
        if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            [locationManager setDelegate:self];
            [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            [locationManager setDistanceFilter:10.0f];
        }
        
        if ([CLLocationManager locationServicesEnabled]) {
            [self setShowUserLocation:YES];
            [locationManager startUpdatingLocation];
        } else {
            [self setShowUserLocation:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationReady object:self.userLocation];
        }
    } else {
        [self showSplashScreen];
    }
    return YES;
}



- (void)rotateImageViewForIpad:(UIImageView *)imageView {
    imageView.transform = CGAffineTransformMakeRotation(M_PI * (-0.5));
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	[self setUserLocation:newLocation];
	 
	if (initLoaded != YES) {
		initLoaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationReady object:self.userLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager setDelegate:nil];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:(error.code == kCLErrorDenied) ? @"Please Allow" : @"Unknown Error"
                          message:@"User Location denied, defaulting to static location."
                          delegate:self
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil
                          ];
    [alert show];
    
    [self setUserLocation:[[CLLocation alloc] initWithLatitude:PDX_LAT longitude:PDX_LON]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationReady object:self.userLocation];
}

- (void)showSplashScreen {	
    [self hideSplashScreen];
    
	splashScreen = [[UIView alloc] init];
	[splashScreen setUserInteractionEnabled:NO];
	
	UIImageView *pbm = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pbm2.png"]];
	UIImageView *base = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"base_blank.png"]];
    [pbm setContentMode:UIViewContentModeScaleAspectFit];
    [base setContentMode:UIViewContentModeScaleAspectFit];
    
    if (self.isPad) {
        [self rotateImageViewForIpad:pbm];
        [self rotateImageViewForIpad:base];
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    screenBounds.origin.y += 10;
	[base setFrame:screenBounds];
	
    if ((activeRegion != nil) && (activeRegion.subdir != nil)) {
        UIImage *regionImage;
		NSString *splashID = [NSString stringWithString:activeRegion.subdir];

        [splashScreen addSubview:base];
        
		if ((regionImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_splash.png", splashID]])) {
            UIImageView *region = [[UIImageView alloc] initWithImage:regionImage];
			[region setFrame:screenBounds];
			[pbm setFrame:screenBounds];
			
            if (self.isPad) {
                [self rotateImageViewForIpad:region];
            }
            
			[splashScreen addSubview:pbm];
			[splashScreen addSubview:region];
		} else {
            screenBounds.origin.y -= 30;
			[pbm setFrame:screenBounds];
			[splashScreen addSubview:pbm];
		}		
	} else {
        [splashScreen addSubview:base];
    }

	[window addSubview:splashScreen];
}

- (void)hideSplashScreen {
    [splashScreen removeFromSuperview];
}

- (void)updateLocationDistances {
	if([activeRegion.locations count] > 0) {
		for (Location *location in activeRegion.locations) {
			[location updateDistance];
		}
	}	
}

- (NSArray *)regions {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Region" inManagedObjectContext:self.managedObjectContext]];
    
    NSArray *regions = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return [regions sortedArrayUsingComparator:^NSComparisonResult(Region *a, Region *b) {
        return [a.name compare:b.name];
    }];
}

- (NSArray *)fetchObjects:(NSString *)type where:(NSString *)field equals:(NSString *)value {
    return [Utils fetchObjects:type where:field equals:value inMOC:self.managedObjectContext];
}

- (id)fetchObject:(NSString *)type where:(NSString *)field equals:(NSString *)value {
    
    return [Utils fetchObject:type where:field equals:value inMOC:self.managedObjectContext];
}

- (NSString *)rootURL {
    NSLog(@"ACTIVE REGION NAME: %@", activeRegion.subdir);
    return [NSString stringWithFormat:@"%@/%@/", BASE_URL, activeRegion.subdir];
}

- (void)showMap:(NSArray*)array withTitle:(NSString *)newTitle {}
- (void)applicationWillTerminate:(UIApplication *)application {}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)resetDatabase {
    [self.persistentStoreCoordinator removePersistentStore:[self.persistentStoreCoordinator persistentStoreForURL:[self storeURL]] error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:[self storeURL] error:nil];
    
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:nil];
}

- (void)saveContext {
    NSLog(@"Save Context");
    NSError *error = nil;
    NSManagedObjectContext *objectContext = self.managedObjectContext;
    if (objectContext != nil) {
        if ([objectContext hasChanges] && ![objectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]; //For multithreading
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSURL *)storeURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"pbm.sqlite"];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
        
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }  
    
    return persistentStoreCoordinator;
}

- (void)checkNetworkStatus:(NSNotification *)notice {
    NetworkStatus internetStatus = [internetReachable_ currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable: {
            internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi: {
            internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN: {
            internetActive = YES;
            
            break;
        }
    }
}

- (bool)noConnectionOrSavedData {
    NSLog(@"ACTIVE REGION: %@", self.activeRegion.name);
    NSLog(@"ACTIVE REGION LOCATION COUNT: %d", [self.activeRegion.locations count]);
    
    return !internetActive && (!self.activeRegion.locations || [self.activeRegion.locations count] == 0);
}

- (bool)noConnectionSavedDataAvailable {
    return !internetActive && ([self.activeRegion.locations count] > 0);
}

- (void)setActiveRegion:(Region *)region {
    [[NSUserDefaults standardUserDefaults] setObject:[region.idNumber stringValue] forKey:@"activeRegionID"];
    
    activeRegion = region;
    NSLog(@"SETTING ACTIVE REGION: %@", activeRegion.name);
    
    APIManager *dm = [[APIManager alloc] init];
    [dm fetchLocationData];
}

@end