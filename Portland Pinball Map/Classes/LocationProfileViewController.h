//
//  LocationProfileViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "XMLTable.h"
#import "MachineProfileViewController.h"
#import "AddMachineViewController.h"
#import "MachineObject.h"
#import "LocationObject.h"
#import "LocationMap.h"
#import <Foundation/Foundation.h>

//@class AddMachineViewController;
//@class LocationObject;

@interface LocationProfileViewController : XMLTable
{
	  
	NSString *message;
	UIScrollView *scrollView;
	NSString *locationID;
	//NSString * currentElement;
	
	LocationMap *mapView;
	
	NSMutableDictionary *masterDictionary;
	//LocationObject *currentLocation;
	
	LocationObject *activeLocationObject;
	
	NSMutableString       *mapURL;
	
	NSMutableDictionary *info;
	
	UILabel   *mapLabel;
	UIButton  *mapButton;
	BOOL       showMapButton;
	
		
	UIView  *lineView;
	
	//Holder Array for Machine Names
	NSMutableArray *label_holder;
	
	//XML Parsing
	//BOOL isParsing;
	BOOL building_machine;
	MachineObject *temp_machine_object;
	NSMutableDictionary *temp_machine_dict;
	NSMutableString *temp_machine_name;
	NSMutableString *temp_machine_id;
	NSMutableString *temp_machine_condition;
	NSMutableString *temp_machine_condition_date;
	NSMutableString *temp_machine_dateAdded;
	
	NSMutableString     *current_street1;
	NSMutableString     *current_street2;
	NSMutableString     *current_city;
	NSMutableString     *current_state;
	NSMutableString     *current_zip;
	NSMutableString     *current_phone;
	
	int					 parsingAttempts;
	
	UIButton *addMachineButton;
	
	AddMachineViewController *addMachineView;
	MachineProfileViewController *machineProfileView;
	
	//New Table Stuff
	NSMutableArray *displayArray;
	//NSMutableArray *infoArray;
	
	

}


@property (nonatomic,retain) MachineProfileViewController *machineProfileView;
@property (nonatomic,retain) AddMachineViewController     *addMachineView;
@property (nonatomic,retain) IBOutlet UIButton *addMachineButton;

@property (nonatomic,assign) BOOL showMapButton;
@property (nonatomic,retain) LocationMap *mapView;
@property (nonatomic,assign) IBOutlet UIView       *lineView;
@property (nonatomic,retain) IBOutlet UILabel      *mapLabel;
@property (nonatomic,retain) IBOutlet UIButton     *mapButton;


@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic,retain) NSString *message;
@property (nonatomic,retain) NSString *locationID;
@property (nonatomic,retain) LocationObject *activeLocationObject;
@property (nonatomic,assign) BOOL building_machine;

//Holder Array for Machine Names
@property (nonatomic,retain) NSMutableArray *label_holder;

//XML Parsing
@property (nonatomic,retain) MachineObject *temp_machine_object;
@property (nonatomic,retain) NSMutableDictionary *temp_machine_dict;
@property (nonatomic,retain) NSMutableString *temp_machine_name;
@property (nonatomic,retain) NSMutableString *temp_machine_id;
@property (nonatomic,retain) NSMutableString *temp_machine_condition_date;
@property (nonatomic,retain) NSMutableString *temp_machine_condition;
@property (nonatomic,retain) NSMutableString *temp_machine_dateAdded;


//Table View Stuff
@property (nonatomic,retain) NSMutableArray *displayArray;

- (IBAction)mapButtonPressed:(id)sender;
- (IBAction)addMachineButtonPressed:(id)sender;


- (void)refreshAndReload;
+ (NSString *)urlDecodeValue:(NSString *)str;
- (void)loadLocationData;
+ (NSString *) urlencode: (NSString *) url;

@end
