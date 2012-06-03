#import "LocationPin.h"

@implementation LocationPin
@synthesize coordinate, location;

- (NSString *)subtitle {	 
	return location.street1;
}

- (NSString *)title {
	return location.name;
}

- (id)initWithLocation:(LocationObject *)newLocation {
	location = newLocation;
	return [self initWithCoordinate:location.coords.coordinate];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c {
 	coordinate = c;
	return self;
}


@end