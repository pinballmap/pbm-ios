#import "LocationObject.h"
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface LocationPin : NSObject <MKAnnotation> {
    LocationObject *location;	
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, strong) LocationObject *location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSString *)title;
- (NSString *)subtitle;
- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (id)initWithLocation:(LocationObject *)newLocation;

@end