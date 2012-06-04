#import "LocationMap.h"
#import "RegionObject.h"
#import "BlackTableViewController.h"

#define MAX_NUMBER_OF_LOCATIONS_TO_SHOW_IN_MAP 25

@interface ClosestLocations : BlackTableViewController {
    LocationMap	*mapView;
	RegionObject *lastViewedRegion;
	NSMutableArray *sectionLocations;
	NSMutableArray *sectionTitles;
    NSMutableArray *allSortedLocations;
}

@property (nonatomic,strong) LocationMap *mapView;
@property (nonatomic,strong) RegionObject *lastViewedRegion;
@property (nonatomic,strong) NSMutableArray *allSortedLocations;
@property (nonatomic,strong) NSMutableArray *sectionLocations;
@property (nonatomic,strong) NSMutableArray *sectionTitles;

- (void)cleanupRegionData;
- (IBAction)onMapButtonTapped:(id)sender;

@end