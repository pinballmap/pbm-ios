#import <CoreLocation/CoreLocation.h>
#import "Region.h"
#import "LocationMap.h"

//#define BASE_URL @"http://glowing-dusk-5085.herokuapp.com"
#define BASE_URL @"http://localhost:3000"

#define METERS_IN_A_MILE 1609.344

@class LocationProfileViewController;

@interface Portland_Pinball_MapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	
	Region *activeRegion;

	UIView *splashScreen;
	CLLocation *userLocation;
	
	LocationProfileViewController *locationProfileView;
	LocationMap *locationMap;
	
	BOOL showUserLocation;
    
@private
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic,strong) CLLocation	*userLocation;
@property (nonatomic,strong) Region *activeRegion;
@property (nonatomic,strong) IBOutlet UIWindow *window;
@property (nonatomic,strong) IBOutlet UINavigationController *navigationController;
@property (nonatomic,strong) LocationProfileViewController *locationProfileView;
@property (nonatomic,strong) LocationMap *locationMap;
@property (nonatomic,strong) UIView	*splashScreen;
@property (nonatomic,assign) BOOL showUserLocation;
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

@end