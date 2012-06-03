#import "AboutViewController.h"
#import "LocationObject.h"
#import "XMLTable.h"
#import "ClosestLocations.h"
#import "RSSViewController.h"
#import "EventsViewController.h"
#import "ZonesViewController.h"
#import "LocationFilterView.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "MachineViewController.h"
#import "BlackTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <stdlib.h>

#define kAcclerationThreshold   2.2;

@class LocationProfileViewController;
@interface RootViewController : XMLTable <CLLocationManagerDelegate,UIAlertViewDelegate,UIAccelerometerDelegate> {
	NSArray *controllers;
	AboutViewController *aboutView;
	
	CLLocationManager *locationManager;
	CLLocation *startingPoint;
	
	NSMutableDictionary *allLocations;
	NSMutableDictionary *allMachines;
	
    NSString *activeNode;
    NSMutableString *current_id;
	NSMutableString *current_name;
	NSMutableString *current_neighborhood;
	NSMutableString *current_numMachines;
	NSMutableString *current_lat;
	NSMutableString *current_lon;
	NSMutableString *current_numLocations;
	NSMutableString *current_shortName;
	NSMutableString *current_isPrimary;
    NSMutableString *current_subdir;
    NSMutableString *current_formalName;
	
    NSArray *tableTitles;
	NSMutableArray *tempRegionArray;
	
	int	parsingAttempts;
	int initID;
	
	BOOL init2Loaded;
    BOOL xmlStarted;
}

@property (nonatomic,strong) CLLocation *startingPoint;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) NSArray  *tableTitles;
@property (nonatomic,strong) NSArray *controllers;
@property (nonatomic,strong) NSMutableArray *tempRegionArray;
@property (nonatomic,strong) NSMutableDictionary *allLocations;
@property (nonatomic,strong) NSMutableDictionary *allMachines;
@property (nonatomic,strong) AboutViewController *aboutView;

- (void)loadInitXML:(int)withID;
- (void)pressInfo:(id)sender;
- (void)showInfoButton;

@end