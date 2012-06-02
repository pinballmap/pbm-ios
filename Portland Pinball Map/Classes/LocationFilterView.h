#import "LocationObject.h"
#import "BlackTableViewController.h"
#import "LocationMap.h"
#import "ZoneObject.h"

@class LocationProfileViewController;
@class Portland_Pinball_MapAppDelegate;

@interface LocationFilterView : BlackTableViewController {
	NSInteger totalLocations;
	NSMutableDictionary *filteredLocations;
    
	NSMutableArray *locationArray;
	NSArray *keys;	
	NSArray	*emptyArray;
	
	ZoneObject *newZone;
	ZoneObject *currentZone;
	
	NSString *zoneID;
	NSString *currentZoneID;
	
	LocationMap *mapView;	
}

@property (nonatomic,retain) NSString *currentZoneID;
@property (nonatomic,retain) NSString *zoneID;
@property (nonatomic,retain) NSMutableDictionary *filteredLocations;
@property (nonatomic,retain) NSArray *keys;
@property (nonatomic,retain) LocationMap *mapView;
@property (nonatomic,retain) NSMutableArray *locationArray;
@property (nonatomic,retain) ZoneObject *newZone;
@property (nonatomic,retain) ZoneObject *currentZone;

- (void)addToFilterDictionary:(LocationObject *)location;
- (void)onMapPress:(id)sender;

@end