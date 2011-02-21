//
//  LocationFilterView.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationObject.h"
#import "BlackTableViewController.h"
#import <UIKit/UIKit.h>
#import "LocationMap.h"
#import "ZoneObject.h"

@class LocationProfileViewController;
@class Portland_Pinball_MapAppDelegate;


@interface LocationFilterView : BlackTableViewController
{
	NSInteger            totalLocations;
	NSMutableDictionary *filteredLocations;
	NSArray             *keys;
	NSMutableArray      *locationArray;
	
	NSArray				*emptyArray;
	
	ZoneObject          *newZone;
	ZoneObject          *currentZone;
	
	NSString			*zoneID;
	NSString			*currentZoneID;
	
	LocationMap			*mapView;
	
	//LocationProfileViewController *childController;
}

@property (nonatomic,retain) NSString            *currentZoneID;
@property (nonatomic,retain) NSString			 *zoneID;
@property (nonatomic,retain) NSMutableDictionary *filteredLocations;
@property (nonatomic,retain) NSArray             *keys;
@property (nonatomic,retain) LocationMap         *mapView;
@property (nonatomic,retain) NSMutableArray      *locationArray;
@property (nonatomic,retain) ZoneObject          *newZone;
@property (nonatomic,retain) ZoneObject			 *currentZone;

-(void) addToFilterDictionary:(LocationObject *)location;
-(void)onMapPress:(id)sender;
@end
