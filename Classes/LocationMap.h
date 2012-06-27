#import "Location.h"
#import "LocationPin.h"
#import <MapKit/MapKit.h>

@interface LocationMap : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
	NSArray *locationsToShow;
	Location *location;
	BOOL showProfileButtons;
}

@property (nonatomic,strong) NSArray *locationsToShow;
@property (nonatomic,strong) MKMapView *map;
@property (nonatomic,strong) Location *location;
@property (nonatomic,assign) BOOL showProfileButtons;

- (void)openGoogleMap;
- (IBAction)googleMapButtonPressed:(id)sender;
- (void)onPinPress:(id)sender;
- (void)loadPins;

@end