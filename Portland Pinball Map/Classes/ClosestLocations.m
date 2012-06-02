#import "ClosestLocations.h"

@implementation ClosestLocations
@synthesize sectionArray, sectionTitles, lastViewedRegion, mapView, allSortedLocations;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapButtonTapped:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(lastViewedRegion != appDelegate.activeRegion) {
		if(sectionArray != nil) {
			sectionTitles = nil;
			sectionArray = nil;
			[sectionTitles release];
			[sectionArray release];
		}
		
		self.tableView.contentOffset = CGPointZero;
		[self.tableView reloadData];
	}
	
	self.title = @"Closest Locations";
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    if (sectionArray != nil) {
        allSortedLocations = nil;
        sectionTitles = nil;
        sectionArray = nil;
        [allSortedLocations release];
        [sectionTitles release];
        [sectionArray release];
    }
    
    sectionTitles = [[NSMutableArray alloc] initWithObjects:@"< 1 mile",@"< 2 miles",@"< 3 miles",@"3+ miles",nil];
    sectionArray  = [[NSMutableArray alloc] initWithCapacity:4];
    allSortedLocations = [[NSMutableArray alloc] initWithCapacity:kNumberOfLocationsToShowInMap];
    
    for(int i = 0; i < 4 ; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [sectionArray addObject:array];
        [array release];
    }
    
    for(id key in appDelegate.activeRegion.locations) {
        LocationObject *location = [appDelegate.activeRegion.locations valueForKey:key];
        [location updateDistance];
        double dist = location.distanceRounded;
        
        int  index;
        if (dist < 1.0) {
            index = 0;
        } else if(dist < 2.0) {
            index = 1;
        } else if(dist < 3.0) {
            index = 2;
        } else {
            index = 3;
        }
        
        NSMutableArray *quickArray = [sectionArray objectAtIndex:index];
        [quickArray addObject:location];
        
        [allSortedLocations addObject:location];
    }
            
    NSSortDescriptor *distanceSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)] autorelease];
    
    [allSortedLocations sortUsingDescriptors:[NSArray arrayWithObjects:distanceSortDescriptor, nil]];

    for(int i = 3; i >= 0 ; i--) {
        NSMutableArray *array = (NSMutableArray*) [sectionArray objectAtIndex:i];
        
        if([array count] > 0) {
            [array sortUsingDescriptors:[NSArray arrayWithObjects:distanceSortDescriptor, nil]];   
        } else {
            [sectionTitles removeObjectAtIndex:i];
            [sectionArray removeObjectAtIndex:i];
        }
    }
		
	[self.tableView reloadData];
	[super viewDidAppear:animated];
	
	lastViewedRegion = appDelegate.activeRegion;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionArray count];
}

- (IBAction) onMapButtonTapped:(id)sender {	
	NSMutableArray *quickArray = [[NSMutableArray alloc] initWithCapacity:kNumberOfLocationsToShowInMap];
	for (int i = 0; i < kNumberOfLocationsToShowInMap; i++) {
		[quickArray addObject:[allSortedLocations objectAtIndex:i]];
	}

	if(mapView == nil) {
		mapView = [[LocationMap alloc] init];
		mapView.showProfileButtons = YES;
	}
	mapView.locationsToShow = quickArray;
	mapView.title = [NSString stringWithFormat:@"Closest %i",kNumberOfLocationsToShowInMap];
	[self.navigationController pushViewController:mapView animated:YES];
	
	[quickArray release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *locationGroup = (NSArray *)[sectionArray objectAtIndex:section];
    return [locationGroup count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [sectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PPMDoubleTableCell *cell = (PPMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[sectionArray objectAtIndex:section];
	LocationObject *location = [locationGroup objectAtIndex:row];
	cell.nameLabel.text = location.name;
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	cell.subLabel.text = (appDelegate.showUserLocation == YES) ? location.distanceString : @"";
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[sectionArray objectAtIndex:section];
	LocationObject *location = [locationGroup objectAtIndex:row];	
	[self showLocationProfile:location  withMapButton:YES];
}

- (void)dealloc {
	[allSortedLocations release];
	[mapView release];
	[lastViewedRegion release];
	[sectionTitles release];
	[sectionArray release];
    [super dealloc];
}

@end