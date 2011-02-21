//
//  LocationMap.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationMap.h"


@implementation LocationMap
@synthesize map;
@synthesize locationsToShow;
@synthesize annotationArray;
@synthesize location;
@synthesize showProfileButtons;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	if(map == nil)
	{
		map = [[MKMapView alloc] initWithFrame:self.view.bounds];
		//map.showsUserLocation = YES;
		map.delegate = self;
		
		MKCoordinateRegion region;
		MKCoordinateSpan span;
		span.latitudeDelta=0.2;
		span.longitudeDelta=0.2;
		region.span = span;
		
		CLLocationCoordinate2D newLoc;// = map.userLocation.coordinate;
		newLoc.latitude  = 45.521744;
		newLoc.longitude = -122.671623;
		region.center=newLoc;
		
		[map setRegion:region animated:NO];
		//[map regionThatFits:region];
		
		[self.view insertSubview:map atIndex:0];
		
	}
	
	//UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	//[infoButton addTarget:self action:@selector(googleMapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
	if (locationsToShow != annotationArray)
	{
		NSLog(@"Removing Annotations");
		
		/*for(int i = [[map annotations] count] - 1; i >= 0; i++)
		{
			//MKAnnotation *annotation = [[map annotations] objectAtIndex:i];
			if([[map annotations] objectAtIndex:i] != map.userLocation)
			{
				[map removeAnnotation:[[map annotations] objectAtIndex:i]];
			}

		}*/
		
		//Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		map.showsUserLocation = NO;
		[map removeAnnotations:map.annotations];
		map.showsUserLocation = YES;
	}
	
	if (locationsToShow != annotationArray)
	{
		annotationArray = locationsToShow;
		MKCoordinateRegion region;
		
		NSMutableArray *quickArray = [[NSMutableArray alloc] initWithCapacity:[annotationArray count]];
		
		if([locationsToShow count] > 1)
		{
			self.navigationItem.rightBarButtonItem = nil;	
			
			CLLocationCoordinate2D southWest;
			CLLocationCoordinate2D northEast;
			
			for (int i = 0; i < [locationsToShow count]; i++)
			{
				LocationObject *newLocation = [locationsToShow objectAtIndex:i];
				LocationPin *placemark = [[LocationPin alloc] initWithLocation:newLocation];
				//[map addAnnotation:placemark];
				[quickArray addObject:placemark];
				[placemark release];
				
				if(i == 0)
				{
					southWest.latitude  = newLocation.coords.coordinate.latitude;
					southWest.longitude = newLocation.coords.coordinate.longitude;
					northEast = southWest;
				}
				
				southWest.latitude  = MIN(southWest.latitude,  newLocation.coords.coordinate.latitude - 0.01);
				southWest.longitude = MIN(southWest.longitude, newLocation.coords.coordinate.longitude + 0.01);
				
				northEast.latitude  = MAX(northEast.latitude,  newLocation.coords.coordinate.latitude + 0.01);
				northEast.longitude = MAX(northEast.longitude, newLocation.coords.coordinate.longitude - 0.01);
			}
			
			region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
			region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
			region.span.latitudeDelta = northEast.latitude - southWest.latitude;
			region.span.longitudeDelta = northEast.longitude - southWest.longitude;
		}
		else
		{
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Google Map" style:UIBarButtonItemStyleBordered target:self action:@selector(googleMapButtonPressed:)] autorelease];	
			
			LocationObject *soloLocation = [locationsToShow objectAtIndex:0];
			LocationPin *soloPlacemark = [[LocationPin alloc] initWithLocation:soloLocation];
			//[map addAnnotation:soloPlacemark];
			[quickArray addObject:soloPlacemark];
			[soloPlacemark release];
			
			region.center.latitude = soloLocation.coords.coordinate.latitude;
			region.center.longitude = soloLocation.coords.coordinate.longitude;
			region.span.latitudeDelta = 0.02;
			region.span.longitudeDelta = 0.02;			
		}
		[map addAnnotations:quickArray];
		[map setRegion:[map regionThatFits:region] animated:NO];
		[quickArray release];
	}
	else
	{
		NSLog(@"Not Updating Map");
	}
	
	[super viewWillAppear:(BOOL)animated];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	//self.map = nil;
}


- (void)dealloc {
	[map release];
	[location release];
	[annotationArray release];
	[locationsToShow release];
    [super dealloc];
}

# pragma mark Google Map Button 

-(IBAction)googleMapButtonPressed:(id)sender
{
	LocationObject *soloLocation = [locationsToShow objectAtIndex:0];
	NSString *mapURL = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=%@,%@ %@, %@ (%@)",
						soloLocation.street1,
						soloLocation.city,
						soloLocation.state,
						soloLocation.zip,
						soloLocation.name];
	NSLog(@"openURL: %@",mapURL);
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURL]];
	UIApplication *app = [UIApplication sharedApplication];
	[app openURL:[[NSURL alloc] initWithString: [mapURL stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
	[mapURL release];
	 
	 /*tempLocation.mapURL = [[NSString alloc] initWithFormat:@"maps://maps.google.com/?f=q&source=s_q&hl=en&geocode=&q=%@&sll=%f,%f&ll=%f,%f&z=15",
	 [current_name stringByReplacingOccurrencesOfString:@" " withString:@"+"],
	 coords.coordinate.latitude,
	 coords.coordinate.longitude,
	 coords.coordinate.latitude,
	 coords.coordinate.longitude];*/

	
	/*UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Exiting App"
						  message:@"Are you sure yo?"
						  delegate:nil
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"Okay",nil];
	[alert show];
	[alert release];
	*/
}

-(void) openGoogleMap
{
		
}


# pragma mark Map View delegate stuff
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
		if(showProfileButtons == NO && [[mapView annotations] lastObject] != mapView.userLocation)
			[mapView selectAnnotation:[[mapView annotations] lastObject] animated:YES];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	MKPinAnnotationView *pin = nil;
	
	if(annotation != mapView.userLocation)
	{
		pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: @"asdf"];
		if (pin == nil) 
		{
			pin = [[[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"asdf"] autorelease];
		}
		
		pin.canShowCallout = YES;
		pin.animatesDrop = NO;
		
		if(showProfileButtons == YES)
		{
			UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
			myDetailButton.frame = CGRectMake(0, 0, 23, 23);
			myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
			
			[myDetailButton addTarget:self action:@selector(onPinPress:) forControlEvents:UIControlEventTouchUpInside];
			
			// Set the image for the button
			[myDetailButton setImage:[UIImage imageNamed:@"arrow3.png"] forState:UIControlStateNormal];
			
			// Set the button as the callout view
			pin.rightCalloutAccessoryView = myDetailButton;
			//annotation.subtitle = @"asdf";
			
		}
		else
		{
			pin.rightCalloutAccessoryView = nil;
			//annotation.subtitle = [[annotation location] street1];
		}
	}
	
	return pin;
}

-(void)onPinPress:(id)sender
{
	LocationObject *pinLocation = [(LocationObject *) [[[sender superview] superview] annotation] location];
	[[[self.navigationController viewControllers] objectAtIndex:0] showLocationProfile:pinLocation  withMapButton:NO];
}




@end
