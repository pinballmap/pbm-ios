//
//  LocationMap.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationPin.h"
#import "LocationObject.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

//#import <LocationProfileViewController.h>
//#import "LocationProfileViewController.h"
//#import "Portland_Pinball_MapAppDelegate.h"

@class LocationProfileViewController;
@class Portland_Pinball_MapAppDelegate;
@interface LocationMap : UIViewController <MKMapViewDelegate>
{
	MKMapView      *map;
	NSArray        *locationsToShow;
	NSArray		   *annotationArray;
	LocationObject *location;
	BOOL            showProfileButtons;
	
}

@property (nonatomic,retain) NSArray        *locationsToShow;
@property (nonatomic,retain) NSArray		*annotationArray;
@property (nonatomic,retain) MKMapView      *map;
@property (nonatomic,retain) LocationObject *location;
@property (nonatomic,assign) BOOL showProfileButtons;

-(void) openGoogleMap;
-(IBAction)googleMapButtonPressed:(id)sender;
-(void)onPinPress:(id)sender;

@end
