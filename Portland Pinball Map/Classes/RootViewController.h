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

@property (nonatomic,retain) CLLocation *startingPoint;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic,retain) NSArray  *tableTitles;
@property (nonatomic,retain) NSArray *controllers;
@property (nonatomic,retain) NSMutableArray *tempRegionArray;
@property (nonatomic,retain) NSMutableDictionary *allLocations;
@property (nonatomic,retain) NSMutableDictionary *allMachines;
@property (nonatomic,retain) AboutViewController *aboutView;

- (void)loadInitXML:(int)withID;
- (void)pressInfo:(id)sender;
- (void)showInfoButton;

@end