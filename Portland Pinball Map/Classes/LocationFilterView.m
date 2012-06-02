#import "LocationFilterView.h"

@implementation LocationFilterView

@synthesize filteredLocations, keys, mapView, locationArray, zoneID, newZone, currentZone, currentZoneID;

- (void)viewDidLoad {
	emptyArray = [[NSArray alloc] init];
	
    [super viewDidLoad];	
}


- (void)viewWillAppear:(BOOL)animated {
	if(![zoneID isEqualToString:currentZoneID]) {
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		self.tableView.contentOffset = CGPointZero;
		
		totalLocations = 0;
		filteredLocations = [[NSMutableDictionary alloc] init];
		locationArray = [[NSMutableArray alloc] init];
		
		for(id key in appDelegate.activeRegion.locations) {
			LocationObject *location = [appDelegate.activeRegion.locations valueForKey:key];
			NSString *neighborhood = location.neighborhood;
			
			if([zoneID isEqualToString:@"All"]) {
                [self addToFilterDictionary:location];
			} else if([zoneID isEqualToString:@"< 1 mile"] && appDelegate.showUserLocation == YES) {
				[location updateDistance];
				if(location.distanceRounded <= 1.0)
                    [self addToFilterDictionary:location];
			} else if([zoneID isEqualToString:appDelegate.activeRegion.machineFilterString]) {
				NSInteger numMachines = location.totalMachines;
				if(numMachines >= [appDelegate.activeRegion.machineFilter intValue]) [self addToFilterDictionary:location];
				
			} else if([neighborhood isEqualToString:newZone.shortName]) {
                [self addToFilterDictionary:location];
            }
		}
		
		for(id key in filteredLocations) {
			NSMutableArray *orig_array = [filteredLocations objectForKey:key];
			NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)] autorelease];
			[orig_array sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
		}
		
		headerHeight = (totalLocations > 25) ? 20 : 0;
		
		NSArray *array = [[filteredLocations allKeys] sortedArrayUsingSelector:@selector(compare:)];
		self.keys = array;
		
		[self.tableView reloadData];
	}
	
	if(currentZoneID != nil)
        [currentZoneID release];
    
	currentZoneID = [[NSString alloc] initWithString:zoneID];
	        
	self.title = [NSString stringWithFormat:[NSString stringWithFormat:@"%@", [zoneID isEqualToString:@"All"] ? @"All Locations" : zoneID]];
	
	if ([keys count] > 0) {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapPress:)] autorelease];
    } else { 
		self.navigationItem.rightBarButtonItem = nil;
	}
        
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	[super viewWillDisappear:animated];
}

- (void)addToFilterDictionary:(LocationObject *)location {
	totalLocations++;
	NSString *locationName = location.name;
	NSString *firstLetter = [[NSString alloc] initWithString:[[locationName substringToIndex:1] lowercaseString]];
	
	NSString *searchString = [[NSString alloc] initWithString:@"abcdefghijklmnopqrstuvwxyz"];
	NSRange letterRange = [searchString rangeOfString:firstLetter];
	if (letterRange.length == 0) {
		[firstLetter release];
		firstLetter = [[NSString alloc] initWithString:@"#"];
	}
	
	
	NSMutableArray *letterArray = [filteredLocations objectForKey:firstLetter];
	if(letterArray == nil) {
		NSMutableArray *newLetterArray = [[NSMutableArray alloc] init];
		[filteredLocations setObject:newLetterArray forKey:firstLetter];
		letterArray = [filteredLocations objectForKey:firstLetter];
		[newLetterArray release];
	}
	
	[letterArray addObject:location];
	[locationArray addObject:location];
	
	[firstLetter release];
	[searchString release];
}

- (void)onMapPress:(id)sender {
	if (mapView == nil) {
		mapView = [[LocationMap alloc] init];
		mapView.showProfileButtons = YES;
	}
	
	mapView.locationsToShow = locationArray;
	mapView.title = self.title;
	
	if (NO) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 1];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
		[self.navigationController pushViewController:mapView animated:YES];
		[UIView commitAnimations];	
	} else {
		[self.navigationController pushViewController:mapView animated:YES];
	}
}



- (void)viewDidUnload {
	[emptyArray release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	NSDictionary *nameSection = [filteredLocations objectForKey:key];
    
    return [nameSection count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	NSString *key = [keys objectAtIndex:section];
	return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return (headerHeight > 0) ? keys : emptyArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PPMDoubleTableCell *cell = (PPMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [keys objectAtIndex:section];
	NSArray *letterArray = (NSArray*)[filteredLocations objectForKey:keyAtSection];
	LocationObject *location = [letterArray objectAtIndex:row];
	cell.nameLabel.text = location.name;
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	cell.subLabel.text = (appDelegate.showUserLocation == YES) ? location.distanceString : @"";

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [keys objectAtIndex:section];
	NSArray *letterArray = (NSArray*)[filteredLocations objectForKey:keyAtSection];
	LocationObject *location = [letterArray objectAtIndex:row];
	
	[self showLocationProfile:location  withMapButton:YES];
}

- (void)dealloc {
	[currentZoneID release];
	[newZone release];
	[currentZone release];
	[emptyArray release];
	[zoneID release];
	[locationArray release];
	[mapView release];
	[keys release];
	[filteredLocations release];
    [super dealloc];
}

@end