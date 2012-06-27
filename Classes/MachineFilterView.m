#import "MachineFilterView.h"
#import "LocationProfileViewController.h"

@implementation MachineFilterView
@synthesize locations, machine, tempLocationID, mapView, resetNavigationStackOnLocationSelect, noLocationsLabel, tempLocations, didAbortParsing;

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
	[self setTitle:machine.name];

	locations = [LocationMachineXref locationsForMachine:machine];
		
	[self.tableView setContentOffset:CGPointZero];
	
	[self reloadLocationData];
	[super viewWillAppear:animated];
}	

- (void)viewDidAppear:(BOOL)animated {
	if (locations == nil) {
		didAbortParsing = NO;
		
		tempLocations = [[NSMutableArray alloc] init];
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
        
        Location *location = (Location *)[appDelegate fetchObject:@"Location" where:@"idNumber" equals:tempLocationID];
		if(location != nil) {
			[location updateDistance];
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	if(didAbortParsing == NO) {
		[self reloadLocationData];
	}
	
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[super parser:parser parseErrorOccurred:parseError];
	[self reloadLocationData];
}

- (void)reloadLocationData {
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