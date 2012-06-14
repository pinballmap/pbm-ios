#import "Location.h"
#import "BlackTableViewController.h"
#import "LocationMap.h"
#import "Zone.h"

@interface LocationFilterView : BlackTableViewController {
	NSInteger totalLocations;
	NSMutableDictionary *filteredLocations;
    
	NSMutableArray *locationArray;
	NSArray *keys;	
	
	Zone *theNewZone;
	Zone *currentZone;
	
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
@property (nonatomic,strong) Zone *theNewZone;
@property (nonatomic,strong) Zone *currentZone;

- (void)addToFilterDictionary:(Location *)location;
- (void)onMapPress:(id)sender;

@end