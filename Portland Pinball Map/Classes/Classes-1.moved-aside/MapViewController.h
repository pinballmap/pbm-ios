//
//  MapViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
}

@property (nonatomic,retain) MKMapView *map;

@end
