#import "Location.h"
#import <MapKit/MapKit.h>

@interface LocationPin : NSObject <MKAnnotation> {
    Location *location;	
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, strong) Location *location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSString *)title;
- (NSString *)subtitle;
- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (id)initWithLocation:(Location *)newLocation;

@end