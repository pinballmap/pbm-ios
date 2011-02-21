//
//  MapViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController
@synthesize map;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	//map = [[MKMapView alloc] initWithFrame:self.view.bounds];
	//map.showsUserLocation = TRUE;
	//map.mapType = MKMapTypeStandard;
	//map.delegate = self;
	
	//[self.view insertSubview:map atIndex:0];
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(void)viewDidAppear:(BOOL)animated
{
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.4;
	span.longitudeDelta=0.4;
	
	CLLocationCoordinate2D location = map.userLocation.coordinate;
	
	location.latitude  = 40.814849;
	location.longitude = -73.622732;
	
	//location.latitude = activeLocationObject.coords.coordinate.latitude;
	//location.longitude = activeLocationObject.coords.coordinate.longitude;
	region.span=span;
	region.center=location;
	
	[map setRegion:region animated:YES];
	//[map regionThatFits:region];
	
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.map = nil;
}


- (void)dealloc {
	[map dealloc];
    [super dealloc];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.animatesDrop=TRUE;
	return annView;
}



@end
