#import "MachineFilterView.h"
#import "LocationProfileViewController.h"
#import "RootViewController.h"

@implementation MachineFilterView
@synthesize locations, machineID, machineName, tempLocationID, mapView, resetNavigationStackOnLocationSelect, noLocationsLabel, tempLocations, didAbortParsing;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	noLocationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
	[noLocationsLabel setText:@"(no locations)"];
	[noLocationsLabel setBackgroundColor:[UIColor blackColor]];
	[noLocationsLabel setTextColor:[UIColor whiteColor]];
	[noLocationsLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[noLocationsLabel setTextAlignment:UITextAlignmentCenter];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:machineName];
	
	if(appDelegate.activeRegion.loadedMachines == nil)
		appDelegate.activeRegion.loadedMachines = [[NSMutableDictionary alloc] init];
	
	locations = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:machineID];
		
	[self.tableView setContentOffset:CGPointZero];
	
	[self reloadLocationData];
	[super viewWillAppear:animated];
}	

- (void)viewDidAppear:(BOOL)animated {
	if (locations == nil) {
		didAbortParsing = NO;
		
		tempLocations = [[NSMutableArray alloc] init];
		
		NSString *url = [[NSString alloc] initWithFormat:@"%@get_machine=%@", appDelegate.rootURL, machineID];
		
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
	if(mapView == nil) {
		mapView = [[LocationMap alloc] init];
		[mapView setShowProfileButtons:YES];
	}
	
	[mapView setLocationsToShow:locations];
	[mapView setTitle:self.title];
	
	[self.navigationController pushViewController:mapView animated:YES];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"id"])
        tempLocationID = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ([currentElement isEqualToString:@"id"])
        [tempLocationID appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {	
	if(didAbortParsing == YES)
        return;
	
	currentElement = @"";
	
	if ([elementName isEqualToString:@"id"]) {		
		Location *location = (Location *)[appDelegate.activeRegion.locations objectForKey:tempLocationID];
		if(location != nil) {
			[location updateDistance];
			[tempLocations addObject:location];
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(didAbortParsing == NO) {
		locations = tempLocations;
		[appDelegate.activeRegion.loadedMachines setObject:locations forKey:machineID];	
		[self reloadLocationData];
	}
	
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[super parser:parser parseErrorOccurred:parseError];
	[self reloadLocationData];
}

-(void)reloadLocationData {
	if (locations == nil) {
		[noLocationsLabel removeFromSuperview];
		[self showLoaderIconLarge];
		
		[self.navigationItem setRightBarButtonItem:nil];
	} else if ([locations count] == 0) {
		[self.tableView setSeparatorColor:[UIColor blackColor]];
		[self.view addSubview:noLocationsLabel];
        
		[self.navigationItem setRightBarButtonItem:nil];
	} else {
		[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
		[noLocationsLabel removeFromSuperview];
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapPress:)]];
		
		NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)];
		for (int i = 0 ; i < [locations count]; i++) {
			Location *locobj = (Location *)[locations objectAtIndex:i];
			[locobj updateDistance];
		}
        
		[locations sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	}
	
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
	static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell = [self getDoubleCell];
    
	Location *location = [locations objectAtIndex:[indexPath row]];
	[cell.nameLabel setText:location.name];
	[cell.subLabel setText:(appDelegate.showUserLocation == YES) ? location.distanceString : @""];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Location *location = [locations objectAtIndex:[indexPath row]];
	
	if(NO) {
		RootViewController *rootController = (RootViewController *)[self.navigationController.viewControllers objectAtIndex:0];
		LocationProfileViewController *locationProfileView = [self getLocationProfile];
		
		[locationProfileView setShowMapButton:YES];
		[locationProfileView setActiveLocationObject:location];
		
		[self.navigationController setViewControllers:[NSArray arrayWithObjects:rootController, self, locationProfileView, nil] animated:NO];
	} else {
		[self showLocationProfile:location withMapButton:YES];
	}
}

@end