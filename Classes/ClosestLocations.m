#import "ClosestLocations.h"

@implementation ClosestLocations
@synthesize sectionLocations, sectionTitles, lastViewedRegion, allSortedLocations;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
	[super viewDidLoad];
    
	appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapButtonTapped:)];
}

- (void)viewWillAppear:(BOOL)animated {
	if (lastViewedRegion != appDelegate.activeRegion) {
		if (sectionLocations != nil)
            [self cleanupRegionData];
		
		[self.tableView setContentOffset:CGPointZero];
		[self.tableView reloadData];
	}
	
	[self setTitle:@"Closest Locations"];
	[super viewWillAppear:animated];
}

- (void)cleanupRegionData {
    allSortedLocations = nil;
    sectionTitles = nil;
    sectionLocations = nil;
}

- (void)viewDidAppear:(BOOL)animated {	
    if (sectionLocations != nil)
        [self cleanupRegionData];
    
    sectionTitles = [[NSMutableArray alloc] initWithObjects:@"< 1 mile", @"< 2 miles", @"< 3 miles", @"3+ miles", nil];
    sectionLocations = [[NSMutableArray alloc] initWithCapacity:[sectionTitles count]];
    allSortedLocations = [[NSMutableArray alloc] initWithCapacity:MAX_NUMBER_OF_LOCATIONS_TO_SHOW_IN_MAP];
    
    for (int i = 0; i < [sectionTitles count]; i++) {
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        [sectionLocations addObject:locations];
    }
    
    for (Location *location in appDelegate.activeRegion.locations) {
        [location updateDistance];
        
        int index;
        if (location.distance < 1.0) {
            index = 0;
        } else if (location.distance < 2.0) {
            index = 1;
        } else if (location.distance < 3.0) {
            index = 2;
        } else {
            index = 3;
        }
        
        NSMutableArray *locationsForSection = [sectionLocations objectAtIndex:index];
        [locationsForSection addObject:location];
        
        [allSortedLocations addObject:location];
    }
            
    NSSortDescriptor *distanceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)];
    
    [allSortedLocations sortUsingDescriptors:@[distanceSortDescriptor]];

    for(int i = 3; i >= 0 ; i--) {
        NSMutableArray *array = (NSMutableArray*) [sectionLocations objectAtIndex:i];
        
        if([array count] > 0) {
            [array sortUsingDescriptors:@[distanceSortDescriptor]];   
        } else {
            [sectionTitles removeObjectAtIndex:i];
            [sectionLocations removeObjectAtIndex:i];
        }
    }
		
	[self.tableView reloadData];
	[super viewDidAppear:animated];
	
	lastViewedRegion = appDelegate.activeRegion;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionLocations count];
}

- (IBAction)onMapButtonTapped:(id)sender {	
	NSMutableArray *mapLocations = [[NSMutableArray alloc] initWithCapacity:MAX_NUMBER_OF_LOCATIONS_TO_SHOW_IN_MAP];
    
	for (int i = 0; i < MAX_NUMBER_OF_LOCATIONS_TO_SHOW_IN_MAP; i++) {
		[mapLocations addObject:[allSortedLocations objectAtIndex:i]];
	}

    [appDelegate.locationMap setShowProfileButtons:YES];
    
	[appDelegate.locationMap setLocationsToShow:mapLocations];
	[appDelegate.locationMap setTitle:[NSString stringWithFormat:@"Closest %i", MAX_NUMBER_OF_LOCATIONS_TO_SHOW_IN_MAP]];
    
	[self.navigationController pushViewController:appDelegate.locationMap animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [(NSArray *)[sectionLocations objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [sectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:@"DoubleTextCellID"];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[sectionLocations objectAtIndex:section];
	Location *location = [locationGroup objectAtIndex:row];
    
	[cell.nameLabel setText:location.name];
	[cell.subLabel setText:(appDelegate.showUserLocation == YES) ? location.formattedDistance : @""];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[sectionLocations objectAtIndex:section];
	Location *location = [locationGroup objectAtIndex:row];	
    
	[self showLocationProfile:location withMapButton:YES];
}

@end