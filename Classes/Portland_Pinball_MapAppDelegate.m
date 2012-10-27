#import "MainMenuViewController.h"
#import "RequestPage.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation Portland_Pinball_MapAppDelegate

@synthesize window, navigationController, splitViewController, splashScreen, locationMap, showUserLocation, activeRegion, userLocation, internetActive, locationManager;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (bool)isPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    splitViewController.delegate = self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
    userLocation = [[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785];
    zonesForLocations = [[NSMutableDictionary alloc] init];

    initLoaded = NO;
    
    NSLog(@"BASE URL: %@", BASE_URL);

    internetReachable_ = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    [internetReachable_ startNotifier];
    [self checkNetworkStatus:nil];
    
    if (self.isPad) {
        navigationController = [[UINavigationController alloc] initWithRootViewController:[[RequestPage alloc] init]];
        navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
        window.rootViewController = splitViewController;
        [window.rootViewController.view setHidden:YES];
    } else {
        locationMap = [[LocationMap alloc] init];
        navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
        [window addSubview:navigationController.view];
	}
    
    [window makeKeyAndVisible];
        
    activeRegion = (Region *)[self fetchObject:@"Region" where:@"idNumber" equals:(NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"activeRegionID"]];

    NSLog(@"SAVED REGION NAME %@", activeRegion.name);
	
    [self showSplashScreen];
    
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
            [self fetchRegionData];
        }
    }
}

- (void)rotateImageViewForIpad:(UIImageView *)imageView {
    imageView.transform = CGAffineTransformMakeRotation(3.14159265 * (-0.5));
}

- (NSDictionary *)fetchedData:(NSData *)data {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return json;
}

- (void)fetchRegionData {
    UIApplication *app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL, @"portland/regions.json"]]];
    [self fetchedRegionData:data];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Region" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedRegions = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    Region *closestRegion = fetchedRegions[0];
    CLLocationDistance closestDistance = 24901.55;
    for (int i = 0; i < [fetchedRegions count]; i++) {
        Region *region = fetchedRegions[i];
        
        CLLocationDistance distance = [self.userLocation distanceFromLocation:[region coordinates]] / METERS_IN_A_MILE;
        
        if(closestDistance > distance) {
            closestRegion = region;
            closestDistance = distance;
        }
    }
    
    [self setActiveRegion:closestRegion];
}

- (void)fetchLocationData {
    UIApplication *app = [UIApplication sharedApplication];
    [app setNetworkActivityIndicatorVisible:YES];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@locations.json", self.rootURL]]];
    [self fetchedLocationData:data];
}

- (void)fetchedRegionData:(NSData *)data {
    NSDictionary *json = [self fetchedData:data];
    NSArray *regions = json[@"regions"];
    
    for (NSDictionary *regionContainer in regions) {
        NSDictionary *regionData = regionContainer[@"region"];
        
        Region *region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:self.managedObjectContext];
        
        NSString *lat = regionData[@"lat"];
        NSString *lon = regionData[@"lon"];
        
        if (lat == (NSString *)[NSNull null]) {
            lat = @"1";
        }
        
        if (lon == (NSString *)[NSNull null]) {
            lon = @"1";
        }
        
        [region setIdNumber:regionData[@"id"]];
        [region setName:regionData[@"name"]];
        [region setFormalName:regionData[@"formalName"]];
        [region setSubdir:regionData[@"subdir"]];
        [region setLat:[NSNumber numberWithInt:[lat intValue]]];
        [region setLon:[NSNumber numberWithInt:[lon intValue]]];
        [region setNMachines:@4];
        
        [self saveContext];        
    }
}

- (void)fetchedLocationData:(NSData *)data {
    NSDictionary *json = [self fetchedData:data];
    
    NSArray *locations = json[@"locations"];
    for (NSDictionary *locationContainer in locations) {
        NSDictionary *locationData = locationContainer[@"location"];
        
        if ([locationData[@"numMachines"] intValue] != 0) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterBehaviorDefault];
            
            NSString *locationID = locationData[@"id"];
            
            Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
            
            if (locationData[@"zoneNo"] != (NSString *)[NSNull null]) {
                [zonesForLocations setValue:locationData[@"zoneNo"] forKey:locationID];
            }
            
            double lon = [locationData[@"lon"] doubleValue];
            double lat = [locationData[@"lat"] doubleValue];
            
            if (lat == 0.0 || lon == 0.0) {
                lat = 45.52295;
                lon = -122.66785;
            }
                        
            [location setIdNumber:[NSNumber numberWithInt:[locationID intValue]]];
            [location setTotalMachines:locationData[@"numMachines"]];
            [location setName:[locationData[@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            [location setLat:@(lat)];
            [location setLon:@(lon)];
            [location setRegion:self.activeRegion];
            [location updateDistance];
            
            [self saveContext];
        }
    }
    
    NSArray *machines = json[@"machines"];
    for (NSDictionary *machineContainer in machines) {
        NSDictionary *machineData = machineContainer[@"machine"];
        
        if ([machineData[@"numLocations"] intValue] != 0) {
            Machine *machine = [NSEntityDescription insertNewObjectForEntityForName:@"Machine" inManagedObjectContext:self.managedObjectContext];
                        
            [machine setIdNumber:machineData[@"id"]];
            [machine setName:[machineData[@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            [machine addRegionObject:self.activeRegion];
            [self.activeRegion addMachinesObject:machine];
            
            [self saveContext];
        }
    }
    
    NSArray *zones = json[@"zones"];
    for (NSDictionary *zoneContainer in zones) {
        NSDictionary *zoneData = zoneContainer[@"zone"];
        
        Zone *zone = [NSEntityDescription insertNewObjectForEntityForName:@"Zone" inManagedObjectContext:self.managedObjectContext];
                
        [zone setName:zoneData[@"name"]];
        [zone setIdNumber:zoneData[@"id"]];
        [zone setIsPrimary:@([zoneData[@"isPrimary"] intValue])];
        [zone setRegion:self.activeRegion];
        [self.activeRegion addZonesObject:zone];
        
        [self saveContext];
    }
        
    for (NSString *locationID in zonesForLocations.allKeys) {
        Zone *zone = (Zone *)[self fetchObject:@"Zone" where:@"idNumber" equals:[zonesForLocations objectForKey:locationID]];
        Location *location = (Location *)[self fetchObject:@"Location" where:@"idNumber" equals:locationID];
        
        [zone addLocationObject:location];
        [location setLocationZone:zone];
        
        [self saveContext];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[self setUserLocation:newLocation];
	
	if (initLoaded != YES) {
		initLoaded = YES;
        [self fetchRegionData];
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
    
    [self setUserLocation:[[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785]];
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
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:type inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = %@", field, value]]];
    
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

- (id)fetchObject:(NSString *)type where:(NSString *)field equals:(NSString *)value {
    NSArray *objects = [self fetchObjects:type where:field equals:value];
    
    return [objects count] > 0 ? objects[0] : nil;
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
        managedObjectContext = [[NSManagedObjectContext alloc] init];
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
}

@end