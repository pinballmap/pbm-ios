#import "MachineFilterView.h"
#import "LocationProfileViewController.h"
#import "RootViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation MachineFilterView
@synthesize locationArray, machineID, machineName, temp_location_id, mapView, resetNavigationStackOnLocationSelect, noLocationsLabel, tempLocationArray, didAbortParsing;

- (void)viewDidLoad {
	noLocationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
	noLocationsLabel.text = @"(no locations)";
	noLocationsLabel.backgroundColor = [UIColor blackColor];
	noLocationsLabel.textColor       = [UIColor whiteColor];
	noLocationsLabel.font            = [UIFont boldSystemFontOfSize:20];
	noLocationsLabel.textAlignment   = UITextAlignmentCenter;
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.title = machineName;
	
	if(appDelegate.activeRegion.loadedMachines == nil)
		appDelegate.activeRegion.loadedMachines = [[NSMutableDictionary alloc] init];
	
	locationArray = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:machineID];
		
	self.tableView.contentOffset = CGPointZero;
	
	[self reloadLocationData];
	[super viewWillAppear:animated];
}	

- (void)viewDidAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (locationArray == nil) {
		didAbortParsing = NO;
		
		if(tempLocationArray != nil) {
			tempLocationArray = nil;
		}
		tempLocationArray = [[NSMutableArray alloc] init];
		
		NSString *url = [[NSString alloc] initWithFormat:@"%@get_machine=%@",appDelegate.rootURL,machineID];
		
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

- (void)viewDidUnload {
	noLocationsLabel = nil;
}



- (void)onMapPress:(id)sender {
	if(mapView == nil) {
		mapView = [[LocationMap alloc] init];
		mapView.showProfileButtons = YES;
	}
	
	mapView.locationsToShow = locationArray;
	mapView.title = self.title;
	
	[self.navigationController pushViewController:mapView animated:YES];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"id"])
        temp_location_id = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ([currentElement isEqualToString:@"id"]) [temp_location_id appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {	
	if(didAbortParsing == YES)
        return;
	
	currentElement = @"";
	
	if ([elementName isEqualToString:@"id"]) {
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		LocationObject *location = (LocationObject *)[appDelegate.activeRegion.locations objectForKey:temp_location_id];
		if(location != nil) {
			[location updateDistance];
			[tempLocationArray addObject:location];
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(didAbortParsing == NO) {
		locationArray = tempLocationArray;
		[appDelegate.activeRegion.loadedMachines setObject:locationArray forKey:machineID];	
		[self reloadLocationData];
	}
	
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[super parser:parser parseErrorOccurred:parseError];
	[self reloadLocationData];
}

-(void)reloadLocationData {
	
	if (locationArray == nil) {
		[noLocationsLabel removeFromSuperview];
		[self showLoaderIconLarge];
		
		self.navigationItem.rightBarButtonItem = nil;
	} else if ([locationArray count] == 0) {
		self.tableView.separatorColor = [UIColor blackColor];
		[self.view addSubview:noLocationsLabel];
		self.navigationItem.rightBarButtonItem = nil;
	} else {
		self.tableView.separatorColor = [UIColor darkGrayColor];
		[noLocationsLabel removeFromSuperview];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapPress:)];
		
		NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)];
		for (int i = 0 ; i < [locationArray count]; i++) {
			LocationObject *locobj = (LocationObject *)[locationArray objectAtIndex:i];
			[locobj updateDistance];
		}
        
		[locationArray sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	}
	
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
	static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PPMDoubleTableCell *cell = (PPMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell = [self getDoubleCell];
    
	NSUInteger row = [indexPath row];
	LocationObject *location = [locationArray objectAtIndex:row];
	cell.nameLabel.text = location.name;
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	cell.subLabel.text = (appDelegate.showUserLocation == YES) ? location.distanceString : @"";
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	LocationObject *location = [locationArray objectAtIndex:row];
	
	if(NO) {
		RootViewController *rootController = (RootViewController *)[self.navigationController.viewControllers objectAtIndex:0];
		LocationProfileViewController *locationProfileView = [self getLocationProfile];
		
		locationProfileView.showMapButton = YES;
		locationProfileView.activeLocationObject = location;
		
		
		NSArray *quickArray = [[NSArray alloc] initWithObjects:rootController,self,locationProfileView,nil];
		[self.navigationController setViewControllers:quickArray animated:NO];
	} else {
		[self showLocationProfile:location  withMapButton:YES];
	}
}

@end