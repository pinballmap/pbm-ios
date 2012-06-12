#import "AboutViewController.h"
#import "XMLTable.h"
#import "ClosestLocations.h"
#import "RSSViewController.h"
#import "EventsViewController.h"
#import "ZonesViewController.h"
#import "MachineViewController.h"
#import <CoreLocation/CoreLocation.h>

#define METERS_IN_A_MILE 1609.344

@interface RootViewController : XMLTable <CLLocationManagerDelegate,UIAlertViewDelegate,UIAccelerometerDelegate> {
	NSArray *controllers;
	AboutViewController *aboutView;
	
	CLLocationManager *locationManager;
	CLLocation *startingPoint;
	
	NSMutableDictionary *allLocations;
	NSMutableDictionary *allMachines;
	
    NSString *activeNode;
    NSMutableString *currentID;
	NSMutableString *currentName;
	NSMutableString *currentNeighborhood;
	NSMutableString *currentNumMachines;
	NSMutableString *currentLat;
	NSMutableString *currentLon;
	NSMutableString *currentNumLocations;
	NSMutableString *currentShortName;
	NSMutableString *currentIsPrimary;
    NSMutableString *currentSubdir;
    NSMutableString *currentFormalName;
	
    NSArray *tableTitles;
	NSMutableArray *regions;
	
	int	parsingAttempts;
	int initID;
	
	BOOL init2Loaded;
    BOOL xmlStarted;
}

@property (nonatomic,strong) CLLocation *startingPoint;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) NSArray  *tableTitles;
@property (nonatomic,strong) NSArray *controllers;
@property (nonatomic,strong) NSMutableArray *regions;
@property (nonatomic,strong) NSMutableDictionary *allLocations;
@property (nonatomic,strong) NSMutableDictionary *allMachines;
@property (nonatomic,strong) AboutViewController *aboutView;

- (void)loadInitXML:(int)withID;
- (void)pressInfo:(id)sender;
- (void)showInfoButton;

@end