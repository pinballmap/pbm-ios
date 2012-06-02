#import "MachineObject.h"
#import "LocationObject.h"
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface LocationPin : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	LocationObject *location;	
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) LocationObject *location;

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (id)initWithLocation:(LocationObject *)newLocation;
- (NSString *)subtitle;
- (NSString *)title;

@end