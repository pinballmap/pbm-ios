//
//  ClosestLocations.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 2/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationMap.h"
#import "RegionObject.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "BlackTableViewController.h"
#import <UIKit/UIKit.h>

#define kNumberOfLocationsToShowInMap 25


@interface ClosestLocations : BlackTableViewController
{
	NSMutableArray *sectionArray;
	NSMutableArray *sectionTitles;
	RegionObject   *lastViewedRegion;
	LocationMap	   *mapView;
	NSMutableArray *allSortedLocations;
}

@property (nonatomic,retain) NSMutableArray *allSortedLocations;
@property (nonatomic,retain) LocationMap    *mapView;
@property (nonatomic,retain) RegionObject   *lastViewedRegion;
@property (nonatomic,retain) NSMutableArray *sectionArray;
@property (nonatomic,retain) NSMutableArray *sectionTitles;

-(IBAction) onMapButtonTapped:(id)sender;

@end
