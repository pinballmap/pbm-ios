#import "LocationPin.h"
#import "LocationObject.h"
#import <MapKit/MapKit.h>

@class LocationProfileViewController;
@class Portland_Pinball_MapAppDelegate;

@interface LocationMap : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
	NSArray *locationsToShow;
	NSArray *annotationArray;
	LocationObject *location;
	BOOL showProfileButtons;
}

@property (nonatomic,strong) NSArray *locationsToShow;
@property (nonatomic,strong) NSArray *annotationArray;
@property (nonatomic,strong) MKMapView *map;
@property (nonatomic,strong) LocationObject *location;
@property (nonatomic,assign) BOOL showProfileButtons;

- (void)openGoogleMap;
- (IBAction)googleMapButtonPressed:(id)sender;
- (void)onPinPress:(id)sender;

@end