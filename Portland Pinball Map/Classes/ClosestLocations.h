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

@property (nonatomic,retain) LocationMap *mapView;
@property (nonatomic,retain) RegionObject *lastViewedRegion;
@property (nonatomic,retain) NSMutableArray *allSortedLocations;
@property (nonatomic,retain) NSMutableArray *sectionLocations;
@property (nonatomic,retain) NSMutableArray *sectionTitles;

- (void)cleanupRegionData;
- (IBAction)onMapButtonTapped:(id)sender;

@end