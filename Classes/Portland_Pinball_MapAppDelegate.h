#import <CoreLocation/CoreLocation.h>
#import "Region.h"
#import "LocationMap.h"
#import "Reachability.h"

#define BASE_URL @"http://pinballmap.com"
//#define BASE_URL @"http://localhost:3000"

#define METERS_IN_A_MILE 1609.344
#define MAX_PARSING_ATTEMPTS 15

@class LocationProfileViewController;
@class Reachability;

@interface Portland_Pinball_MapAppDelegate : NSObject <UIApplicationDelegate, UISplitViewControllerDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	UISplitViewController *splitViewController;

	Region *activeRegion;

	UIView *splashScreen;
	CLLocation *userLocation;	
	LocationMap *locationMap;
	
	BOOL showUserLocation;
    BOOL internetActive;
    
    Reachability *internetReachable_;
    
@private
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic,strong) CLLocation	*userLocation;
@property (nonatomic,strong) Region *activeRegion;
@property (nonatomic,strong) IBOutlet UIWindow *window;
@property (nonatomic,strong) IBOutlet UINavigationController *navigationController;
@property (nonatomic,strong) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic,strong) IBOutlet LocationMap *locationMap;
@property (nonatomic,strong) UIView	*splashScreen;
@property (nonatomic,assign) BOOL showUserLocation;
@property (nonatomic,assign) BOOL internetActive;
@property (nonatomic,strong,readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong,readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong,readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)showMap:(NSArray *)array withTitle:(NSString *)newTitle;
- (void)updateLocationDistances;
- (void)hideSplashScreen;
- (void)showSplashScreen;
- (NSString *)rootURL;
- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)resetDatabase;
- (NSArray *)regions;
- (NSArray *)fetchObject:(NSString *)type where:(NSString *)field equals:(NSString *)value;
- (NSArray *)fetchObjects:(NSString *)type where:(NSString *)field equals:(NSString *)value;
- (bool)isPad;
- (bool)noConnectionOrSavedData;
- (bool)noConnectionSavedDataAvailable;
- (void)checkNetworkStatus:(NSNotification *)notice;

@end