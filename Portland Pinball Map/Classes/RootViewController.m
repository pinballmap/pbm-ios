#import "RootViewController.h"
#import "ZoneObject.h"
#import "RegionSelectViewController.h"

@implementation RootViewController
@synthesize locationManager, startingPoint, controllers, allLocations, allMachines, aboutView, tableTitles, tempRegionArray;

Portland_Pinball_MapAppDelegate *appDelegate;

- (id)initWithFrame:(CGRect)frame {
    parsingAttempts = 0;
    init2Loaded = NO;
    
    return self;
}

- (BOOL)canBecomeFirstResponder {
	return YES;
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
	
    [self setTitle:[NSString stringWithFormat:@"%@ Pinball Map", appDelegate.activeRegion.name]];
    
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {	
	if(self.locationManager == nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate:self];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[locationManager setDistanceFilter:10.0f];
		
		if (locationManager.locationServicesEnabled == YES) {
			[appDelegate setShowUserLocation:YES];
			[locationManager startUpdatingLocation];
		} else {
			[appDelegate setShowUserLocation:NO];
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
	[self setTitle:@"back"];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	self.aboutView = nil;
	[super viewDidUnload];
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
        
        currentID = [[NSMutableString alloc] init];
        currentName = [[NSMutableString alloc] init];
        currentNeighborhood = [[NSMutableString alloc] init];
        currentNumMachines = [[NSMutableString alloc] init];
        currentLat = [[NSMutableString alloc] init];
        currentLon = [[NSMutableString alloc] init];
        currentNumLocations = [[NSMutableString alloc] init];
        currentShortName = [[NSMutableString alloc] init];
        currentIsPrimary = [[NSMutableString alloc] init];
        currentSubdir = [[NSMutableString alloc] init];
        currentFormalName = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (initID == 2) {
        if([activeNode isEqualToString:@"region"] && ![string isEqualToString:@"\n"]) {
            if ([currentElement isEqualToString:@"id"])
                [currentID appendString:string];
            if ([currentElement isEqualToString:@"name"])
                [currentName appendString:string];
            if ([currentElement isEqualToString:@"formalName"])
                [currentFormalName appendString:string];
            if ([currentElement isEqualToString:@"lat"])
                [currentLat appendString:string];
            if ([currentElement isEqualToString:@"lon"])
                [currentLon appendString:string];
            if ([currentElement isEqualToString:@"subdir"])
                [currentSubdir appendString:string];
        }         
    } else {
        if([activeNode isEqualToString:@"location"]) {
            if ([currentElement isEqualToString:@"id"])           
                [currentID appendString:string];
            if ([currentElement isEqualToString:@"name"])         
                [currentName appendString:string];
            if ([currentElement isEqualToString:@"neighborhood"]) 
                [currentNeighborhood appendString:string];
            if ([currentElement isEqualToString:@"numMachines"])  
                [currentNumMachines appendString:string];
            if ([currentElement isEqualToString:@"lat"])          
                [currentLat appendString:string];
            if ([currentElement isEqualToString:@"lon"])          
                [currentLon appendString:string];
        } else if([activeNode isEqualToString:@"machine"]) {
            if ([currentElement isEqualToString:@"id"])           
                [currentID appendString:string];
            if ([currentElement isEqualToString:@"name"])         
                [currentName appendString:string];
            if ([currentElement isEqualToString:@"numLocations"]) 
                [currentNumLocations appendString:string];
        } else if([activeNode isEqualToString:@"zone"]) {
            if ([currentElement isEqualToString:@"id"])           
                [currentID appendString:string];
            if ([currentElement isEqualToString:@"name"])         
                [currentName appendString:string];
            if ([currentElement isEqualToString:@"shortName"])    
                [currentShortName appendString:string];
            if ([currentElement isEqualToString:@"isPrimary"])    
                [currentIsPrimary appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (initID == 2) {
        if ([elementName isEqualToString:@"region"]) {
            RegionObject *regionobject = [[RegionObject alloc] init];
            [regionobject setIdNumber:currentID];
            [regionobject setName:currentName];
            [regionobject setFormalName:currentFormalName];
            [regionobject setSubdir:currentSubdir];
            [regionobject setLat:currentLat];
            [regionobject setLon:currentLon];
            [regionobject setMachineFilter:@"4"];
            [regionobject setMachineFilterString:[NSString stringWithFormat:@"%@+ Machines", regionobject.machineFilter]];
            
            if (tempRegionArray == nil)
                tempRegionArray = [[NSMutableArray alloc] init];
            
            [tempRegionArray addObject:regionobject];
        }
    } else {
        if ([elementName isEqualToString:@"location"]) {
            if([currentNumMachines intValue] != 0) {
                LocationObject *tempLocation = [[LocationObject alloc] init];
                
                double lon = [currentLon doubleValue];
                double lat = [currentLat doubleValue];
                
                if(lat == 0.0 || lon == 0.0) {
                    lat = 45.52295;
                    lon = -122.66785;
                }
                
                CLLocation *coords = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                
                [tempLocation setIdNumber:currentID];
                [tempLocation setTotalMachines:[currentNumMachines intValue]];
                [tempLocation setName:currentName];
                [tempLocation setNeighborhood:currentNeighborhood];
                [tempLocation setCoords:coords];
                [tempLocation updateDistance];
                
                if(allLocations == nil)
                    allLocations = [[NSMutableDictionary alloc] init];
				
                [allLocations setObject:tempLocation forKey:currentID];
            }
            
        } else if ([elementName isEqualToString:@"machine"]) {
            if([currentNumLocations intValue] != 0) {
                NSMutableDictionary *tempMachine = [[NSMutableDictionary alloc] init];
                [tempMachine setValue:currentID forKey:@"id"];
                [tempMachine setValue:currentName forKey:@"name"];
                [tempMachine setValue:currentNumLocations forKey:@"numLocations"];
				
                if(allMachines == nil)
                    allMachines  = [[NSMutableDictionary alloc] init];
                
                [allMachines setObject:tempMachine forKey:currentID];
            }
            
        } else if ([elementName isEqualToString:@"zone"]) {            
            ZoneObject *zone = [[ZoneObject alloc] init];
            [zone setName:currentName];
            [zone setIdNumber:currentID];
            [zone setShortName:currentShortName];
            [zone setIsPrimary:currentIsPrimary];
            
            if(appDelegate.activeRegion.primaryZones == nil)
                appDelegate.activeRegion.primaryZones = [[NSMutableArray alloc] init];
            if(appDelegate.activeRegion.secondaryZones == nil)
                appDelegate.activeRegion.secondaryZones = [[NSMutableArray alloc] init];
            
            ([zone.isPrimary isEqualToString:@"1"]) ?
                [appDelegate.activeRegion.primaryZones addObject:zone] :
                [appDelegate.activeRegion.secondaryZones addObject:zone];
        }        
    }

	currentElement = @"";
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (initID == 2) {
        [appDelegate setRegions:tempRegionArray];
        
        RegionObject *closestRegion = [appDelegate.regions objectAtIndex:0];
        CLLocationDistance closestDistance = 24901.55;
        for (int i = 0; i < [appDelegate.regions count]; i++) {
            RegionObject *reg = [appDelegate.regions objectAtIndex:i];
            
            double lon = [reg.lon doubleValue];
            double lat = [reg.lat doubleValue];
            
            CLLocation *coords = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            CLLocationDistance distance = [appDelegate.userLocation getDistanceFrom:coords] / 1609.344;
            
            if(closestDistance > distance) {
                closestRegion = reg;
                closestDistance = distance;
            }
        }
        
        [appDelegate setActiveRegion:closestRegion];
        [appDelegate showSplashScreen];
        
        [self setTitle:[NSString stringWithFormat:@"%@ Pinball Map", appDelegate.activeRegion.name]];

        xmlStarted = NO;
        @autoreleasepool {
			[self performSelectorInBackground:@selector(loadInitXML:) withObject:nil];
        }
    } else {
        [appDelegate.activeRegion setMachines:self.allMachines];
        [appDelegate.activeRegion setLocations:self.allLocations];

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
            
            RSSViewController *rssView = [[RSSViewController alloc] initWithStyle:UITableViewStylePlain];
            [rssView setTitle:@"Recently Added"];
            [viewControllers addObject:rssView];
            
            EventsViewController *eventView = [[EventsViewController alloc] initWithStyle:UITableViewStylePlain];
            [eventView setTitle:@"Events"];
            [viewControllers addObject:eventView];
            
            RegionSelectViewController *regionselect = [[RegionSelectViewController alloc] initWithStyle:UITableViewStylePlain];
            [regionselect setTitle:@"Change Region"];
            [viewControllers addObject:regionselect];
            
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
		
		if (initID == 1) {
			allLocations = [[NSMutableDictionary alloc] init];
			allMachines  = [[NSMutableDictionary alloc] init];
		} else if(initID == 2) {
			tempRegionArray = nil;
		}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [controllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
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

-(void)pressInfo:(id)sender {
	if(aboutView == nil) {
		aboutView = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
		[aboutView setTitle:@"About"];
	}
	
	[self.navigationController pushViewController:aboutView animated:YES];
}

@end