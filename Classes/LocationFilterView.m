#import "Utils.h"
#import "Zone.h"
#import "LocationFilterView.h"

@implementation LocationFilterView
@synthesize filteredLocations, keys, mapView, locations, zoneID, theNewZone, currentZone, currentZoneID;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    [super viewDidLoad];	
}

- (void)viewWillAppear:(BOOL)animated {
	if (![zoneID isEqualToString:currentZoneID]) {		
		[self.tableView setContentOffset:CGPointZero];
		
        locations = [[NSMutableArray alloc] init];
		filteredLocations = [[NSMutableDictionary alloc] init];
		
		for (Location *location in appDelegate.activeRegion.locations) {			
			if ([zoneID isEqualToString:@"All"]) {
                [self addToFilterDictionary:location];
			} else if([zoneID isEqualToString:@"< 1 mile"] && appDelegate.showUserLocation == YES) {
				[location updateDistance];
				if(location.distance <= 1.0)
                    [self addToFilterDictionary:location];
			} else if([zoneID isEqualToString:appDelegate.activeRegion.formattedNMachines]) {
				if(location.totalMachines >= appDelegate.activeRegion.nMachines)
                    [self addToFilterDictionary:location];
			} else if([location.locationZone.idNumber isEqualToNumber:theNewZone.idNumber]){
                [self addToFilterDictionary:location];
            }
		}
        
        for (NSString *key in filteredLocations.allKeys) {            
            NSArray *sortedLocations = [filteredLocations objectForKey:key];
            sortedLocations = (NSMutableArray *)[sortedLocations sortedArrayUsingComparator:^NSComparisonResult(Location *a, Location *b) {
                return [a.name compare:b.name];
            }];
            
            [filteredLocations setObject:sortedLocations forKey:key];
        }

		[self setKeys:[[filteredLocations allKeys] sortedArrayUsingSelector:@selector(compare:)]];
		
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

- (void)addToFilterDictionary:(Location *)location {
	NSString *firstLetter = [Utils directoryFirstLetter:location.name];
    
	NSMutableArray *letterArray = [filteredLocations objectForKey:firstLetter];
	if(letterArray == nil) {
		NSMutableArray *newLetterArray = [[NSMutableArray alloc] init];
		[filteredLocations setObject:newLetterArray forKey:firstLetter];
		letterArray = [filteredLocations objectForKey:firstLetter];
	}
	
	[letterArray addObject:location];
	[locations addObject:location];
}

- (void)onMapPress:(id)sender {
	if (mapView == nil) {
		mapView = [[LocationMap alloc] init];
		[mapView setShowProfileButtons:YES];
	}
	
	[mapView setLocationsToShow:locations];
	[mapView setTitle:self.title];
	
    [self.navigationController pushViewController:mapView animated:YES];
}

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
    return ([locations count] > 25) ? keys : [[NSArray alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:@"DoubleTextCellID"];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray*)[filteredLocations objectForKey:keyAtSection];
	Location *location = [letterArray objectAtIndex:[indexPath row]];
    [cell.nameLabel setText:location.name];
	[cell.subLabel setText:(appDelegate.showUserLocation == YES) ? location.formattedDistance : @""];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray*)[filteredLocations objectForKey:keyAtSection];
	Location *location = [letterArray objectAtIndex:[indexPath row]];
	
	[self showLocationProfile:location withMapButton:YES];
}

@end