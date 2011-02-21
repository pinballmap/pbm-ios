//
//  RootViewController.h
//  Portland Pinball Map
//
//  Created By Isaac Ruiz on 11/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

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
@interface RootViewController : XMLTable 
	<CLLocationManagerDelegate,UIAlertViewDelegate,UIAccelerometerDelegate>
{
	NSArray *controllers;
	AboutViewController *aboutView;
	
	NSArray *tableTitles;
	
	
	CLLocationManager *locationManager;
	CLLocation        *startingPoint;
	
	NSMutableDictionary *allLocations;
	NSMutableDictionary *allMachines;
	
	//All Locations/Machines Building
	NSString            *activeNode;
	BOOL                xmlStarted;

	//Common
	NSMutableString     *current_id;
	NSMutableString     *current_name;
	
	//Locations
	NSMutableString     *current_neighborhood;
	NSMutableString     *current_numMachines;
	NSMutableString     *current_lat;
	NSMutableString     *current_lon;
	
	//Machines
	NSMutableString     *current_numLocations;
	
	//Zones
	NSMutableString     *current_shortName;
	NSMutableString     *current_isPrimary;
	
	//Regions
	NSMutableArray      *tempRegionArray;
	NSMutableString     *current_subdir;
	NSMutableString     *current_formalName;
	
	int					 parsingAttempts;
	int                  initID;
	
	BOOL                 init2Loaded;
}

@property (nonatomic,retain) NSMutableArray *tempRegionArray;
@property (nonatomic,retain) NSArray  *tableTitles;
@property (nonatomic,retain) CLLocation *startingPoint;
@property (nonatomic,retain) CLLocationManager *locationManager;

@property (nonatomic,retain) NSArray *controllers;
@property (nonatomic,retain) NSMutableDictionary *allLocations;
@property (nonatomic,retain) NSMutableDictionary *allMachines;
@property (nonatomic,retain) AboutViewController *aboutView;

-(void)loadInitXML:(int)withID;
-(void)pressInfo:(id)sender;
-(void)showInfoButton;

@end
