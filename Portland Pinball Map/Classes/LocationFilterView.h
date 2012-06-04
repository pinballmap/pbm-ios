#import "LocationObject.h"
#import "BlackTableViewController.h"
#import "LocationMap.h"
#import "ZoneObject.h"

@interface LocationFilterView : BlackTableViewController {
	NSInteger totalLocations;
	NSMutableDictionary *filteredLocations;
    
	NSMutableArray *locationArray;
	NSArray *keys;	
	
	ZoneObject *theNewZone;
	ZoneObject *currentZone;
	
	NSString *zoneID;
	NSString *currentZoneID;
	
	LocationMap *mapView;	
}

@property (nonatomic,strong) NSString *currentZoneID;
@property (nonatomic,strong) NSString *zoneID;
@property (nonatomic,strong) NSMutableDictionary *filteredLocations;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,strong) LocationMap *mapView;
@property (nonatomic,strong) NSMutableArray *locationArray;
@property (nonatomic,strong) ZoneObject *theNewZone;
@property (nonatomic,strong) ZoneObject *currentZone;

- (void)addToFilterDictionary:(LocationObject *)location;
- (void)onMapPress:(id)sender;

@end