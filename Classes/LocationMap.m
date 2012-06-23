#import "LocationMap.h"
#import "BlackTableViewController.h"

@implementation LocationMap
@synthesize map, locationsToShow, annotationArray, location, showProfileButtons;

- (void)viewDidLoad {
	if(map == nil) {
		map = [[MKMapView alloc] initWithFrame:self.view.bounds];
		[map setDelegate:self];
		
		MKCoordinateRegion region;
		MKCoordinateSpan span;
		span.latitudeDelta = 0.2;
		span.longitudeDelta = 0.2;
		region.span = span;
		
		CLLocationCoordinate2D newLoc;
		newLoc.latitude  = 45.521744;
		newLoc.longitude = -122.671623;
		region.center = newLoc;
		
		[map setRegion:region animated:NO];
		
		[self.view insertSubview:map atIndex:0];		
	}

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	if (locationsToShow != annotationArray) {
		[map setShowsUserLocation:NO];
		[map removeAnnotations:map.annotations];
		[map setShowsUserLocation:YES];
	}
	
	if (locationsToShow != annotationArray) {
		annotationArray = locationsToShow;
		MKCoordinateRegion region;
		
		NSMutableArray *quickArray = [[NSMutableArray alloc] initWithCapacity:[annotationArray count]];
		
		if([locationsToShow count] > 1) {
			self.navigationItem.rightBarButtonItem = nil;	
			
			CLLocationCoordinate2D southWest;
			CLLocationCoordinate2D northEast;
			
			for (int i = 0; i < [locationsToShow count]; i++) {
				Location *newLocation = [locationsToShow objectAtIndex:i];
				LocationPin *placemark = [[LocationPin alloc] initWithLocation:newLocation];
				[quickArray addObject:placemark];
				
				if(i == 0) {
					southWest.latitude  = newLocation.coordinates.coordinate.latitude;
					southWest.longitude = newLocation.coordinates.coordinate.longitude;
					northEast = southWest;
				}
				
				southWest.latitude  = MIN(southWest.latitude,  newLocation.coordinates.coordinate.latitude - 0.01);
				southWest.longitude = MIN(southWest.longitude, newLocation.coordinates.coordinate.longitude + 0.01);
				
				northEast.latitude  = MAX(northEast.latitude,  newLocation.coordinates.coordinate.latitude + 0.01);
				northEast.longitude = MAX(northEast.longitude, newLocation.coordinates.coordinate.longitude - 0.01);
			}
			
			region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
			region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
			region.span.latitudeDelta = northEast.latitude - southWest.latitude;
			region.span.longitudeDelta = northEast.longitude - southWest.longitude;
		} else {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Google Map" style:UIBarButtonItemStyleBordered target:self action:@selector(googleMapButtonPressed:)];	
			
			Location *soloLocation = [locationsToShow objectAtIndex:0];
			LocationPin *soloPlacemark = [[LocationPin alloc] initWithLocation:soloLocation];
			[quickArray addObject:soloPlacemark];
			
			region.center.latitude = soloLocation.coordinates.coordinate.latitude;
			region.center.longitude = soloLocation.coordinates.coordinate.longitude;
			region.span.latitudeDelta = 0.02;
			region.span.longitudeDelta = 0.02;			
		}
		[map addAnnotations:quickArray];
		[map setRegion:[map regionThatFits:region] animated:NO];
	}
	
	[super viewWillAppear:(BOOL)animated];
}


- (IBAction)googleMapButtonPressed:(id)sender {
	Location *soloLocation = [locationsToShow objectAtIndex:0];
	NSString *mapURL = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=%@,%@ %@, %@ (%@)", soloLocation.street1, soloLocation.city, soloLocation.state, soloLocation.zip, soloLocation.name];
	UIApplication *app = [UIApplication sharedApplication];
	[app openURL:[[NSURL alloc] initWithString: [mapURL stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
}

- (void)openGoogleMap {}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if(showProfileButtons == NO && [[mapView annotations] lastObject] != mapView.userLocation)
        [mapView selectAnnotation:[[mapView annotations] lastObject] animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
	MKPinAnnotationView *pin = nil;
	
	if(annotation != mapView.userLocation) {
		pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: @"asdf"];
		if (pin == nil) {
			pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"asdf"];
		}
		
		pin.canShowCallout = YES;
		pin.animatesDrop = NO;
		
		if(showProfileButtons == YES) {
			UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
			myDetailButton.frame = CGRectMake(0, 0, 23, 23);
			myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
			
			[myDetailButton addTarget:self action:@selector(onPinPress:) forControlEvents:UIControlEventTouchUpInside];
			
			[myDetailButton setImage:[UIImage imageNamed:@"arrow3.png"] forState:UIControlStateNormal];
			pin.rightCalloutAccessoryView = myDetailButton;			
		} else {
			pin.rightCalloutAccessoryView = nil;
		}
	}
	
	return pin;
}

- (void)onPinPress:(id)sender {
	Location *pinLocation = (Location *)[sender location];
    
	[(BlackTableViewController *)[[self.navigationController viewControllers] objectAtIndex:0] showLocationProfile:pinLocation withMapButton:NO];
}

@end