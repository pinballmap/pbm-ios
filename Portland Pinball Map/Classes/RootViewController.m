#import "RootViewController.h"
#import "ZoneObject.h"
#import "RegionSelectViewController.h"

@implementation RootViewController
@synthesize locationManager, startingPoint, controllers, allLocations, allMachines, aboutView, tableTitles, tempRegionArray;

- (id)initWithFrame:(CGRect)frame {
    parsingAttempts = 0;
    init2Loaded = NO;
    
    return self;
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)viewDidLoad {
	tableTitles = [[NSArray alloc] initWithObjects:@"Locations",@"Machines",@"Closest Locations",@"Recently Added",@"Events",@"Change Region",nil];
	
	[self showInfoButton];
	
	[super viewDidLoad];
}

-(void)showInfoButton {
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(pressInfo:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];	
}

- (void)viewWillAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.title = [NSString stringWithFormat:@"%@ Pinball Map",appDelegate.activeRegion.name];
	[super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(self.locationManager == nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.distanceFilter = 10.0f;
		
		if(locationManager.locationServicesEnabled == YES) {
			appDelegate.showUserLocation = YES;
			[locationManager startUpdatingLocation];
		} else {
			appDelegate.showUserLocation = NO;
			[self loadInitXML:2];
		}
	} else if (appDelegate.activeRegion.locations == nil) {
		if(allMachines != nil) {
			allMachines  = nil;
			allLocations = nil;
		}
		[appDelegate showSplashScreen];
		xmlStarted = NO;
		@autoreleasepool {
			[self performSelectorInBackground:@selector(loadInitXML:) withObject:nil];
		}
	}
	
	[super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.aboutView = nil;
	[super viewDidUnload];
}


- (void)loadInitXML:(int)withID {
	if(xmlStarted == YES) return;
	xmlStarted = YES;

	initID = withID;
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	[self showLoaderIcon];
	
	NSString *path;
	switch (withID) {
		case 2:
			path = [[NSString alloc] initWithFormat:@"http://pinballmap.com/iphone.html?init=2"];
			init2Loaded = YES;
			break;
		case 1:
		default:
			path = [[NSString alloc] initWithFormat:@"%@init=1",appDelegate.rootURL];
			break;
	}
    
	@autoreleasepool {
		[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(appDelegate.userLocation != nil) {
		appDelegate.userLocation = nil;
		appDelegate.userLocation;
	}
	appDelegate.userLocation = newLocation;
	
	if(init2Loaded != YES) {
		init2Loaded = YES;
		[self loadInitXML:2];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    [self.locationManager stopUpdatingLocation];
    self.locationManager;
    self.locationManager.delegate = nil;
		
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Please Allow" : @"Unknown Error";
    UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle:errorType
        message:@"User Location denied, defaulting to static location."
        delegate:self
        cancelButtonTitle:@"Okay"
        otherButtonTitles:nil
    ];
    
    [alert show];

    appDelegate.userLocation = [[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	currentElement = [elementName copy];
	
	switch (initID) {
		case 2:
			if ([elementName isEqualToString:@"region"]) {
				activeNode            = @"region";
				current_id            = [[NSMutableString     alloc] init];
				current_name          = [[NSMutableString     alloc] init];
				current_formalName    = [[NSMutableString     alloc] init];
				current_lat           = [[NSMutableString     alloc] init];
				current_lon           = [[NSMutableString     alloc] init];
				current_subdir        = [[NSMutableString     alloc] init];
			}
			break;
		default:
		case 1:
			if ([elementName isEqualToString:@"location"]) {
				activeNode            = @"location";
				current_id            = [[NSMutableString     alloc] init];
				current_name          = [[NSMutableString     alloc] init];
				current_numMachines   = [[NSMutableString     alloc] init];
				current_lat           = [[NSMutableString     alloc] init];
				current_lon           = [[NSMutableString     alloc] init];
				current_neighborhood  = [[NSMutableString     alloc] init];
			} else if ([elementName isEqualToString:@"machine"]) {
				activeNode            = @"machine";
				
				current_id            = [[NSMutableString     alloc] init];
				current_name          = [[NSMutableString     alloc] init];
				current_numLocations  = [[NSMutableString     alloc] init];
			} else if ([elementName isEqualToString:@"zone"]) {
				activeNode            = @"zone";
				
				current_id            = [[NSMutableString     alloc] init];
				current_name          = [[NSMutableString     alloc] init];
				current_shortName     = [[NSMutableString     alloc] init];
				current_isPrimary     = [[NSMutableString     alloc] init];
				
			}
			break;
	}
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
	switch (initID) {
		case 2:
			if([activeNode isEqualToString:@"region"] && ![string isEqualToString:@"\n"]) {
				if ([currentElement isEqualToString:@"id"])           [current_id appendString:string];
				if ([currentElement isEqualToString:@"name"])         [current_name appendString:string];
				if ([currentElement isEqualToString:@"formalName"])   [current_formalName appendString:string];
				if ([currentElement isEqualToString:@"lat"])          [current_lat appendString:string];
				if ([currentElement isEqualToString:@"lon"])          [current_lon appendString:string];
				if ([currentElement isEqualToString:@"subdir"])       [current_subdir appendString:string];
			}
			break;
        default:
		case 1:
			if([activeNode isEqualToString:@"location"]) {
				if ([currentElement isEqualToString:@"id"])           [current_id appendString:string];
				if ([currentElement isEqualToString:@"name"])         [current_name appendString:string];
				if ([currentElement isEqualToString:@"neighborhood"]) [current_neighborhood appendString:string];
				if ([currentElement isEqualToString:@"numMachines"])  [current_numMachines appendString:string];
				if ([currentElement isEqualToString:@"lat"])          [current_lat appendString:string];
				if ([currentElement isEqualToString:@"lon"])          [current_lon appendString:string];
			} else if([activeNode isEqualToString:@"machine"]) {
				if ([currentElement isEqualToString:@"id"])           [current_id appendString:string];
				if ([currentElement isEqualToString:@"name"])         [current_name appendString:string];
				if ([currentElement isEqualToString:@"numLocations"]) [current_numLocations appendString:string];
			} else if([activeNode isEqualToString:@"zone"]) {
				if ([currentElement isEqualToString:@"id"])           [current_id appendString:string];
				if ([currentElement isEqualToString:@"name"])         [current_name appendString:string];
				if ([currentElement isEqualToString:@"shortName"])    [current_shortName appendString:string];
				if ([currentElement isEqualToString:@"isPrimary"])    [current_isPrimary appendString:string];
			}
			break;
	}
	
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
		
	switch (initID) {
		case 2:
			if ([elementName isEqualToString:@"region"]) {
				RegionObject *regionobject = [[RegionObject alloc] init];
				regionobject.idNumber  = current_id;
				regionobject.name       = current_name;
				regionobject.formalName = current_formalName;
				regionobject.subdir     = current_subdir;
				regionobject.lat        = current_lat;
				regionobject.lon        = current_lon;
				regionobject.machineFilter = ([regionobject.name isEqualToString:@"Portland"]) ? @"4" : @"3";
				regionobject.machineFilterString = [NSString stringWithFormat:@"%@+ Machines",regionobject.machineFilter];
									
				if(tempRegionArray == nil)
					tempRegionArray = [[NSMutableArray alloc] init];
			
				[tempRegionArray addObject:regionobject];
				
			}
			
			break;
		default:
		case 1:
			if ([elementName isEqualToString:@"location"]) {
				if([current_numMachines intValue] != 0) {
                    LocationObject *tempLocation = [[LocationObject alloc] init];
					
					double lon = [current_lon doubleValue];
					double lat = [current_lat doubleValue];
					
					if(lat == 0.0 || lon == 0.0) {
						lat = 45.52295;
						lon = -122.66785;
					}
					
					CLLocation *coords  = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
					
					tempLocation.id_number         = current_id;
					tempLocation.totalMachines     = [current_numMachines intValue];
					tempLocation.name              = current_name;
					tempLocation.neighborhood      = current_neighborhood;
					tempLocation.coords            = coords;
					[tempLocation updateDistance];
					
					if(allLocations == nil)
						allLocations = [[NSMutableDictionary alloc] init];
				
					[allLocations setObject:tempLocation forKey:current_id];
					
					
				}
				
			} else if ([elementName isEqualToString:@"machine"]) {
				if([current_numLocations intValue] != 0) {
					NSMutableDictionary *tempMachine = [[NSMutableDictionary alloc] init];
					[tempMachine setValue:current_id forKey:@"id"];
					[tempMachine setValue:current_name forKey:@"name"];
					[tempMachine setValue:current_numLocations forKey:@"numLocations"];
				
					if(allMachines == nil)
						allMachines  = [[NSMutableDictionary alloc] init];
					
					[allMachines setObject:tempMachine forKey:current_id];
				}
				
			} else if ([elementName isEqualToString:@"zone"]) {
				Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
				
				ZoneObject *zone = [[ZoneObject alloc] init];
				zone.name = current_name;
				zone.idNumber = current_id;
				zone.shortName = current_shortName;
				zone.isPrimary = current_isPrimary;
				
				if(appDelegate.activeRegion.primaryZones == nil)  appDelegate.activeRegion.primaryZones = [[NSMutableArray alloc] init];
				if(appDelegate.activeRegion.secondaryZones == nil) appDelegate.activeRegion.secondaryZones = [[NSMutableArray alloc] init];
				
				if([zone.isPrimary isEqualToString:@"1"]) {
					[appDelegate.activeRegion.primaryZones addObject:zone];
				} else {
					[appDelegate.activeRegion.secondaryZones addObject:zone];
                }
				
				
			}
			break;
	}
	
	currentElement = @"";
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
	switch (initID) {
		case 2:
        {
            appDelegate.regions = tempRegionArray;
			
			RegionObject       *closestRegion   = [appDelegate.regions objectAtIndex:1];
			CLLocationDistance  closestDistance = 24901.55;
			for (int i = 0; i < [appDelegate.regions count]; i++) {
				RegionObject *reg = [appDelegate.regions objectAtIndex:i];
				
				double lon = [reg.lon doubleValue];
				double lat = [reg.lat doubleValue];
				
				CLLocation *coords  = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
				CLLocationDistance distance = [appDelegate.userLocation getDistanceFrom:coords] / 1609.344;
				
				if(closestDistance > distance) {
					closestRegion   = reg;
					closestDistance = distance;
				}
			}
			
			[appDelegate newActiveRegion:closestRegion];
			[appDelegate showSplashScreen];
			
			self.title = [NSString stringWithFormat:@"%@ Pinball Map",appDelegate.activeRegion.name];

						
			xmlStarted = NO;
			@autoreleasepool {
			[self performSelectorInBackground:@selector(loadInitXML:) withObject:nil];
			}
        }
			break;
		case 1:
        {
			appDelegate.activeRegion.machines  = self.allMachines;
			appDelegate.activeRegion.locations = self.allLocations;
			
			if(self.controllers == nil) {
				NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:6];
				
				ZonesViewController *locView = [[ZonesViewController alloc] initWithStyle:UITableViewStylePlain];
				locView.title = @"Locations";
				[array addObject:locView];
				
				MachineViewController *machView = [[MachineViewController alloc] initWithStyle:UITableViewStylePlain];
				machView.title = @"Machines";
				[array addObject:machView];
				
				ClosestLocations *closest = [[ClosestLocations alloc] initWithStyle:UITableViewStylePlain];
				closest.title = @"Closest Locations";
				[array addObject:closest];
				
				RSSViewController *rssView = [[RSSViewController alloc] initWithStyle:UITableViewStylePlain];
				rssView.title = @"Recently Added";
				[array addObject:rssView];
				
				EventsViewController *eventView = [[EventsViewController alloc] initWithStyle:UITableViewStylePlain];
				eventView.title = @"Events";
				[array addObject:eventView];
				
				RegionSelectViewController *regionselect = [[RegionSelectViewController alloc] initWithStyle:UITableViewStylePlain];
				regionselect.title = @"Change Region";
				[array addObject:regionselect];
				
				self.controllers = array;
			}
			
			[appDelegate hideSplashScreen];
			[self.tableView reloadData];
			[self hideLoaderIcon];
        }
			break;
        default:
        {}
            break;
	}
    
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	if(parsingAttempts < 15) {
		parsingAttempts ++;
		
		if(initID == 1) {
			
			allLocations = [[NSMutableDictionary alloc] init];
			allMachines  = [[NSMutableDictionary alloc] init];
		} else if(initID == 2) {
			tempRegionArray = nil;
		}

		xmlStarted = NO;
		
		[self loadInitXML:initID];
		
	} else {
		[self hideLoaderIcon];

		NSString *errorType = [[NSString alloc] initWithString:@"Please close the app and try again."];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"No Internet Connection Found"
							  message:errorType
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
	}	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [controllers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SingleTextID";
    
    PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getTableCell];
	}
    
	NSUInteger row = [indexPath row];
	cell.nameLabel.text = [tableTitles objectAtIndex:row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger row = [indexPath row];
	UITableViewController *nextController = [self.controllers objectAtIndex:row];
	[self.navigationController pushViewController:nextController animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {	
	if(buttonIndex == 0)
		[self loadInitXML:2];
}

-(void)pressInfo:(id)sender {
	if(aboutView == nil) {
		aboutView = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
		aboutView.title = @"About";
	}
	
	[self.navigationController pushViewController:aboutView animated:YES];
}

@end