#import "RootViewController.h"
#import "Zone.h"
#import "RegionSelectViewController.h"

@implementation RootViewController
@synthesize locationManager, startingPoint, controllers, aboutView, tableTitles;

Portland_Pinball_MapAppDelegate *appDelegate;

- (id)initWithFrame:(CGRect)frame {
    parsingAttempts = 0;
    init2Loaded = NO;
    
    return self;
}

- (void)viewDidLoad {
	tableTitles = [[NSArray alloc] initWithObjects:@"Locations", @"Machines", @"Closest Locations", @"Recently Added", @"Events", @"Change Region", nil];
    
	[self showInfoButton];
	
	[super viewDidLoad];
}

-(void)showInfoButton {
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(pressInfo:) forControlEvents:UIControlEventTouchUpInside];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:infoButton]];	
}

- (void)viewWillAppear:(BOOL)animated {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setTitle:[NSString stringWithFormat:@"%@ Pinball Map", appDelegate.activeRegion.formalName]];
    
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {	
	if(self.locationManager == nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate:self];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[locationManager setDistanceFilter:10.0f];
		
		if ([CLLocationManager locationServicesEnabled]) {
			[appDelegate setShowUserLocation:YES];
			[locationManager startUpdatingLocation];
		} else {
			[appDelegate setShowUserLocation:NO];
			[self loadInitXML:2];
		}
	} else if (appDelegate.activeRegion.locations == nil) {
        [appDelegate showSplashScreen];
		
        xmlStarted = NO;
		
        @autoreleasepool {
			[self performSelectorInBackground:@selector(loadInitXML:) withObject:nil];
		}
	}
	
	[super viewDidAppear:animated];
}

- (void)loadInitXML:(int)withID {
	if(xmlStarted == YES)
        return;
    
	xmlStarted = YES;

	initID = withID;
	[self showLoaderIcon];
	
	NSString *path = [NSString stringWithFormat:@"%@", withID == 2 ?
        [NSString stringWithFormat:@"%@/%@", BASE_URL, @"iphone.html?init=2"] :
        [NSString stringWithFormat:@"%@init=1", appDelegate.rootURL]
    ];
        
	@autoreleasepool {
		[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {	
	[appDelegate setUserLocation:newLocation];
	
	if (init2Loaded != YES) {
		init2Loaded = YES;
		[self loadInitXML:2];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {	
    [self.locationManager stopUpdatingLocation];
    [self.locationManager setDelegate:nil];
		
    UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle:(error.code == kCLErrorDenied) ? @"Please Allow" : @"Unknown Error"
        message:@"User Location denied, defaulting to static location."
        delegate:self
        cancelButtonTitle:@"Okay"
        otherButtonTitles:nil
    ];
    [alert show];

    [appDelegate setUserLocation:[[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentElement = [elementName copy];
        
    if ([[NSArray arrayWithObjects:@"region", @"location", @"machine", @"zone", nil] containsObject:elementName]) {
        activeNode = elementName;
        
        currentID = [[NSNumber alloc] init];
        currentName = [[NSMutableString alloc] init];
        currentNumMachines = [[NSNumber alloc] init];
        currentLat = [[NSNumber alloc] init];
        currentLon = [[NSNumber alloc] init];
        currentNumLocations = [[NSNumber alloc] init];
        currentShortName = [[NSMutableString alloc] init];
        currentIsPrimary = false;
        currentSubdir = [[NSMutableString alloc] init];
        currentFormalName = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

    if (initID == 2) {
        if([activeNode isEqualToString:@"region"] && ![string isEqualToString:@"\n"]) {
            [formatter setNumberStyle:NSNumberFormatterBehaviorDefault];
            if ([currentElement isEqualToString:@"id"])
                currentID = [formatter numberFromString:string];
            
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            if ([currentElement isEqualToString:@"lat"])
                currentLat = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"lon"])
                currentLon = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"name"])
                [currentName appendString:string];
            if ([currentElement isEqualToString:@"formalName"])
                [currentFormalName appendString:string];
            if ([currentElement isEqualToString:@"subdir"])
                [currentSubdir appendString:string];
        }         
    } else {
        if([activeNode isEqualToString:@"location"]) {
            [formatter setNumberStyle:NSNumberFormatterBehaviorDefault];
            if ([currentElement isEqualToString:@"id"])
                currentID = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"numMachines"])
                currentNumMachines = [formatter numberFromString:string];
            
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            if ([currentElement isEqualToString:@"lat"])
                currentLat = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"lon"])
                currentLon = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"name"])         
                [currentName appendString:string];
        } else if([activeNode isEqualToString:@"machine"]) {
            if ([currentElement isEqualToString:@"id"])     
                currentID = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"numLocations"])
                currentNumLocations = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"name"])         
                [currentName appendString:string];
        } else if([activeNode isEqualToString:@"zone"]) {
            [formatter setNumberStyle:NSNumberFormatterBehaviorDefault];
            if ([currentElement isEqualToString:@"id"])
                currentID = [formatter numberFromString:string];
            if ([currentElement isEqualToString:@"isPrimary"])   
                currentIsPrimary = [string boolValue];
            if ([currentElement isEqualToString:@"name"])         
                [currentName appendString:string];
            if ([currentElement isEqualToString:@"shortName"])    
                [currentShortName appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (initID == 2) {
        if ([elementName isEqualToString:@"region"]) {
            Region *region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:appDelegate.managedObjectContext];
            
            [region setIdNumber:currentID];
            [region setName:currentName];
            [region setFormalName:currentFormalName];
            [region setSubdir:currentSubdir];
            [region setLat:currentLat];
            [region setLon:currentLon];
            [region setNMachines:[NSNumber numberWithInt:4]];
            
            [appDelegate saveContext];
        }
    } else {
        if ([elementName isEqualToString:@"location"]) {
            if([currentNumMachines intValue] != 0) {
                Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:appDelegate.managedObjectContext];
                
                double lon = [currentLon doubleValue];
                double lat = [currentLat doubleValue];
                
                if (lat == 0.0 || lon == 0.0) {
                    lat = 45.52295;
                    lon = -122.66785;
                }
                                
                [location setIdNumber:currentID];
                [location setTotalMachines:currentNumMachines];
                [location setName:currentName];
                [location setLat:[NSNumber numberWithDouble:lat]];
                [location setLon:[NSNumber numberWithDouble:lon]];
                [location setRegion:appDelegate.activeRegion];
                [location updateDistance];
                
                [appDelegate saveContext];
            }
        } else if ([elementName isEqualToString:@"machine"]) {
            if([currentNumLocations intValue] != 0) {
                Machine *machine = [NSEntityDescription insertNewObjectForEntityForName:@"Machine" inManagedObjectContext:appDelegate.managedObjectContext];
                [machine setValue:currentID forKey:@"idNumber"];
                [machine setValue:currentName forKey:@"name"];
                
                [appDelegate saveContext];
            }
        } else if ([elementName isEqualToString:@"zone"]) {            
            Zone *zone = [NSEntityDescription insertNewObjectForEntityForName:@"Zone" inManagedObjectContext:appDelegate.managedObjectContext];
            [zone setName:currentName];
            [zone setIdNumber:currentID];
            [zone setIsPrimary:[NSNumber numberWithBool:currentIsPrimary]];
        }        
    }

	currentElement = @"";
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (initID == 2) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Region"
                                                  inManagedObjectContext:appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedRegions = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        Region *closestRegion = [fetchedRegions objectAtIndex:0];
        CLLocationDistance closestDistance = 24901.55;
        for (int i = 0; i < [fetchedRegions count]; i++) {
            Region *region = [fetchedRegions objectAtIndex:i];
            
            CLLocationDistance distance = [appDelegate.userLocation distanceFromLocation:[region coordinates]] / METERS_IN_A_MILE;
            
            if(closestDistance > distance) {
                closestRegion = region;
                closestDistance = distance;
            }
        }
        
        [appDelegate setActiveRegion:closestRegion];
        [appDelegate showSplashScreen];
        
        [self setTitle:[NSString stringWithFormat:@"%@ Pinball Map", appDelegate.activeRegion.formalName]];

        xmlStarted = NO;
        @autoreleasepool {
			[self performSelectorInBackground:@selector(loadInitXML:) withObject:nil];
        }
    } else {
        if(self.controllers == nil) {
            NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
            
            ZonesViewController *locView = [[ZonesViewController alloc] initWithStyle:UITableViewStylePlain];
            [locView setTitle:@"Locations"];
            [viewControllers addObject:locView];
            
            MachineViewController *machView = [[MachineViewController alloc] initWithStyle:UITableViewStylePlain];
            [machView setTitle:@"Machines"];
            [viewControllers addObject:machView];
            
            ClosestLocations *closest = [[ClosestLocations alloc] initWithStyle:UITableViewStylePlain];
            [closest setTitle:@"Closest Locations"];
            [viewControllers addObject:closest];
            
            RecentlyAddedViewController *rssView = [[RecentlyAddedViewController alloc] initWithStyle:UITableViewStylePlain];
            [rssView setTitle:@"Recently Added"];
            [viewControllers addObject:rssView];
            
            EventsViewController *eventView = [[EventsViewController alloc] initWithStyle:UITableViewStylePlain];
            [eventView setTitle:@"Events"];
            [viewControllers addObject:eventView];
            
            RegionSelectViewController *regionSelect = [[RegionSelectViewController alloc] initWithStyle:UITableViewStylePlain];
            [regionSelect setTitle:@"Change Region"];
            [viewControllers addObject:regionSelect];
            
            [self setControllers:viewControllers];
        }

        [appDelegate hideSplashScreen];
        [self.tableView reloadData];
        [self hideLoaderIcon];
	}
    
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {	
	if (parsingAttempts < 15) {
		parsingAttempts ++;
		
		xmlStarted = NO;
		
		[self loadInitXML:initID];
	} else {
		[self hideLoaderIcon];

		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"No Internet Connection Found"
							  message:@"Please close the app and try again."
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
	}	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [controllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PBMTableCell *cell = (PBMTableCell*)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
    if (cell == nil) {
		cell = [self getTableCell];
	}
    
	[cell.nameLabel setText:[tableTitles objectAtIndex:[indexPath row]]];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.navigationController pushViewController:[self.controllers objectAtIndex:[indexPath row]] animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {	
	if(buttonIndex == 0)
		[self loadInitXML:2];
}

- (void)pressInfo:(id)sender {
	if(aboutView == nil) {
		aboutView = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
		[aboutView setTitle:@"About"];
	}
	
	[self.navigationController pushViewController:aboutView animated:YES];
}

@end