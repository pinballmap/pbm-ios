#import "Region.h"
#import "BlackTableViewController.h"

#define MAX_NUMBER_OF_LOCATIONS_TO_SHOW_IN_MAP 25

@interface ClosestLocations : BlackTableViewController {
	Region *lastViewedRegion;

	NSMutableArray *sectionLocations;
	NSMutableArray *sectionTitles;
    NSMutableArray *allSortedLocations;
}

@property (nonatomic,strong) Region *lastViewedRegion;
@property (nonatomic,strong) NSMutableArray *allSortedLocations;
@property (nonatomic,strong) NSMutableArray *sectionLocations;
@property (nonatomic,strong) NSMutableArray *sectionTitles;

- (void)cleanupRegionData;
- (IBAction)onMapButtonTapped:(id)sender;

@end