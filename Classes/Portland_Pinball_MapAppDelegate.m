#import "MainMenuViewController.h"
#import "RequestPage.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation Portland_Pinball_MapAppDelegate

@synthesize window, navigationController, splitViewController, splashScreen, locationMap, showUserLocation, activeRegion, userLocation;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (bool)isPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (void) awakeFromNib{
    [super awakeFromNib];
    
    splitViewController.delegate = self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
    userLocation = [[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785];

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
		
    [self resetDatabase];
	[self showSplashScreen];
}

- (void)rotateImageViewForIpad:(UIImageView *)imageView {
    imageView.transform = CGAffineTransformMakeRotation(3.14159265 * (-0.5));
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
    screenBounds.origin.y += 20;
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
    
    return [objects count] > 0 ? [objects objectAtIndex:0] : nil;
}

- (NSString *)rootURL {
    return [NSString stringWithFormat:@"%@/%@/iphone.html?", BASE_URL, activeRegion.subdir];
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

@end