#import "LocationFilterView.h"
#import "Utils.h"

@implementation LocationFilterView
@synthesize filteredLocations, keys, mapView, locationArray, zoneID, theNewZone, currentZone, currentZoneID;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    [super viewDidLoad];	
}

- (void)viewWillAppear:(BOOL)animated {
	if(![zoneID isEqualToString:currentZoneID]) {		
		[self.tableView setContentOffset:CGPointZero];
		
		totalLocations = 0;
		filteredLocations = [[NSMutableDictionary alloc] init];
		locationArray = [[NSMutableArray alloc] init];
		
		for (id key in appDelegate.activeRegion.locations) {
			LocationObject *location = [appDelegate.activeRegion.locations valueForKey:key];
			
			if ([zoneID isEqualToString:@"All"]) {
                [self addToFilterDictionary:location];
			} else if([zoneID isEqualToString:@"< 1 mile"] && appDelegate.showUserLocation == YES) {
				[location updateDistance];
				if(location.distanceRounded <= 1.0)
                    [self addToFilterDictionary:location];
			} else if([zoneID isEqualToString:appDelegate.activeRegion.machineFilterString]) {
				if(location.totalMachines >= [appDelegate.activeRegion.machineFilter intValue])
                    [self addToFilterDictionary:location];
			} else if([location.neighborhood isEqualToString:theNewZone.shortName]) {
                [self addToFilterDictionary:location];
            }
		}
		
		headerHeight = (totalLocations > 25) ? 20 : 0;		
		self.keys = [[filteredLocations allKeys] sortedArrayUsingSelector:@selector(compare:)];
		
		[self.tableView reloadData];
	}

	currentZoneID = zoneID;
    
	[self setTitle:[NSString stringWithFormat:[NSString stringWithFormat:@"%@", [zoneID isEqualToString:@"All"] ? @"All Locations" : zoneID]]];
	
    [self.navigationItem setRightBarButtonItem:([keys count] > 0) ?
        [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapPress:)] :
        nil
    ];
        
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self setTitle:@"back"];
    
	[super viewWillDisappear:animated];
}

- (void)addToFilterDictionary:(LocationObject *)location {
	totalLocations++;
	NSString *firstLetter = [Utils directoryFirstLetter:location.name];
    
	NSMutableArray *letterArray = [filteredLocations objectForKey:firstLetter];
	if(letterArray == nil) {
		NSMutableArray *newLetterArray = [[NSMutableArray alloc] init];
		[filteredLocations setObject:newLetterArray forKey:firstLetter];
		letterArray = [filteredLocations objectForKey:firstLetter];
	}
	
	[letterArray addObject:location];
	[locationArray addObject:location];
}

- (void)onMapPress:(id)sender {
	if (mapView == nil) {
		mapView = [[LocationMap alloc] init];
		[mapView setShowProfileButtons:YES];
	}
	
	[mapView setLocationsToShow:locationArray];
	[mapView setTitle:self.title];
	
	if (NO) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 1];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
	}
    
    [self.navigationController pushViewController:mapView animated:YES];
}

- (void)viewDidUnload {}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *nameSection = [filteredLocations objectForKey:[keys objectAtIndex:section]];
    
    return [nameSection count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	return [keys objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return (headerHeight > 0) ? keys : [[NSArray alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PPMDoubleTableCell *cell = (PPMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray*)[filteredLocations objectForKey:keyAtSection];
	LocationObject *location = [letterArray objectAtIndex:[indexPath row]];
    [cell.nameLabel setText:location.name];
	[cell.subLabel setText:(appDelegate.showUserLocation == YES) ? location.distanceString : @""];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray*)[filteredLocations objectForKey:keyAtSection];
	LocationObject *location = [letterArray objectAtIndex:[indexPath row]];
	
	[self showLocationProfile:location withMapButton:YES];
}

@end