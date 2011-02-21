//
//  MachineFilterView.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//@class Portland_Pinball_MapAppDelegate;
#import "XMLTable.h"
#import "LocationMap.h"
#import "LocationObject.h"
#import <Foundation/Foundation.h>


@interface MachineFilterView : XMLTable {
	
	NSMutableArray *locationArray;
	NSMutableArray *tempLocationArray;
	
	NSString *machineID;
	NSString *machineName;
	NSMutableString *temp_location_id;
	
	UILabel *noLocationsLabel;
	
	BOOL resetNavigationStackOnLocationSelect;
	BOOL didAbortParsing;
	
	LocationMap			*mapView;
}
@property (nonatomic,assign) BOOL didAbortParsing;
@property (nonatomic,retain) NSMutableArray *tempLocationArray;
@property (nonatomic,retain) UILabel *noLocationsLabel;
@property (nonatomic,assign) BOOL resetNavigationStackOnLocationSelect;
@property (nonatomic,retain) LocationMap         *mapView;
@property (nonatomic,retain) NSString *temp_location_id;
@property (nonatomic,retain) NSArray *locationArray;
@property (nonatomic,retain) NSString *machineID;
@property (nonatomic,retain) NSString *machineName;

-(void)onMapPress:(id)sender;
-(void)reloadLocationData;

@end

