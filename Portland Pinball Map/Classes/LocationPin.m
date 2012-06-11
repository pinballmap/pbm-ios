#import "LocationPin.h"

@implementation LocationPin
@synthesize coordinate, location;

- (NSString *)subtitle {	 
    return location.street1;
}

- (NSString *)title {
	return location.name;
}

- (id)initWithLocation:(Location *)newLocation {
	location = newLocation;

	return [self initWithCoordinate:location.coords.coordinate];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate {
 	coordinate = newCoordinate;
    
	return self;
}

@end