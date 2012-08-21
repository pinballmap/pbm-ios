#import "MachineFilterView.h"
#import "LocationMachineXref.h"
#import "LocationProfileViewController.h"

@implementation MachineFilterView
@synthesize locations, machine, foundLocation, resetNavigationStackOnLocationSelect, didAbortParsing;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

    foundLocation = [[NSMutableDictionary alloc] init];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:machine.name];

	locations = [LocationMachineXref locationsForMachine:machine];

	[self reloadLocationData];
    
	[super viewWillAppear:animated];
}	

- (void)viewDidAppear:(BOOL)animated {
	if (locations == nil || [locations count] == 0) {
		didAbortParsing = NO;
		
		NSString *url = [[NSString alloc] initWithFormat:@"%@get_machine=%@", appDelegate.rootURL, machine.idNumber];

		@autoreleasepool {
			[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:url];
		}
	}
	
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	if (isParsing == YES) {
		didAbortParsing = YES;
	}
	
	[super viewWillDisappear:animated];
}

- (void)onMapPress:(id)sender {
    [appDelegate.locationMap setShowProfileButtons:YES];
	[appDelegate.locationMap setLocationsToShow:locations];
	[appDelegate.locationMap setTitle:self.title];
	
	[self.navigationController pushViewController:appDelegate.locationMap animated:YES];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentElement = [elementName copy];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    for (NSString *property in @[@"id", @"street1", @"street2", @"city", @"state", @"zip", @"phone"]) {
        if ([property isEqualToString:currentElement]) {
            [foundLocation setObject:string forKey:property];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {	
	if(didAbortParsing == YES) {
        return;
    }
	
	currentElement = @"";
	
	if ([elementName isEqualToString:@"phone"]) {
        Location *location = (Location *)[appDelegate fetchObject:@"Location" where:@"idNumber" equals:[foundLocation objectForKey:@"id"]];

        if (![LocationMachineXref findForMachine:machine andLocation:location]) {
            LocationMachineXref *lmx = [NSEntityDescription insertNewObjectForEntityForName:@"LocationMachineXref" inManagedObjectContext:appDelegate.managedObjectContext];
            [lmx setLocation:location];
            [lmx setMachine:machine];
            
            [appDelegate saveContext];
        }
        
        [locations addObject:location];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	if (didAbortParsing == NO) {
        for (Location *location in locations) {
            [location setStreet1:[foundLocation objectForKey:@"street1"]];
            [location setStreet2:[foundLocation objectForKey:@"street2"]];
            [location setCity:[foundLocation objectForKey:@"city"]];
            [location setState:[foundLocation objectForKey:@"state"]];
            [location setZip:[foundLocation objectForKey:@"zip"]];
            [location setPhone:[foundLocation objectForKey:@"phone"]];
            [location updateDistance]; 
        }
    }
    
    [self reloadLocationData];
	
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[super parser:parser parseErrorOccurred:parseError];
	[self reloadLocationData];
}

- (void)reloadLocationData {
	if (locations == nil || [locations count] == 0) {
		[self.tableView setSeparatorColor:[UIColor blackColor]];        
		[self.navigationItem setRightBarButtonItem:nil];
	} else {
		[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
        
        if (!appDelegate.isPad) {
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapPress:)]];
		}
            
		NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)];
		for (int i = 0 ; i < [locations count]; i++) {
			Location *location = (Location *)[locations objectAtIndex:i];
			[location updateDistance];
		}
        
		[locations sortUsingDescriptors:@[nameSortDescriptor]];
	}
	
	[self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {        
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:@"DoubleTextCellID"];
    if (cell == nil)
		cell = [self getDoubleCell];
    
	Location *location = [locations objectAtIndex:[indexPath row]];
	[cell.nameLabel setText:location.name];
	[cell.subLabel setText:(appDelegate.showUserLocation == YES) ? location.formattedDistance : @""];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Location *location = [locations objectAtIndex:[indexPath row]];
	
    return [self showLocationProfile:location withMapButton:YES];
}

@end