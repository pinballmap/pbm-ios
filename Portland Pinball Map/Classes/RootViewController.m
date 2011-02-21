//
//  RootViewController.m
//  Portland Pinball Map
//
//  Created By Isaac Ruiz on 11/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "ZoneObject.h"
#import "RegionSelectViewController.h"


@implementation RootViewController
@synthesize locationManager;
@synthesize startingPoint;
@synthesize controllers;
@synthesize allLocations;
@synthesize allMachines;
@synthesize aboutView;
@synthesize tableTitles;
@synthesize tempRegionArray;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
        parsingAttempts = 0;
		init2Loaded = NO;
    }
    return self;
}

-(BOOL) canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidLoad 
{
	tableTitles = [[NSArray alloc] initWithObjects:@"Locations",@"Machines",@"Closest Locations",@"Recently Added",@"Events",@"Change Region",nil];
	
	[self showInfoButton];
	
	[super viewDidLoad];
}

-(void)showInfoButton
{
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(pressInfo:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];
	
}

- (void)viewWillAppear:(BOOL)animated 
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.title = [NSString stringWithFormat:@"%@ Pinball Map",appDelegate.activeRegion.name];
	[super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(self.locationManager == nil)
	{
		self.locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.distanceFilter = 10.0f;
		
		if(locationManager.locationServicesEnabled == YES)
		{
			appDelegate.showUserLocation = YES;
			[locationManager startUpdatingLocation];
		}
		else 
		{
			NSLog(@"services not enabled");
			appDelegate.showUserLocation = NO;
			[self loadInitXML:2];
		}
	}
	else if (appDelegate.activeRegion.locations == nil)
	{
		if(allMachines != nil)
		{
			allMachines  = nil;
			allLocations = nil;
			[allMachines release];
			[allLocations release];
		}
		[appDelegate showSplashScreen];
		xmlStarted = NO;
		//[self loadInitXML:1];
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[self performSelectorInBackground:@selector(loadInitXML:) withObject:nil];
		[pool release];
	}
	
	[super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
	

	self.title = @"back";
	//self.navigationItem.rightBarButtonItem = nil;
	
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	self.aboutView = nil;
	[super viewDidUnload];
}

- (void)dealloc
{
	[tempRegionArray release];
	[activeNode release];
	[aboutView release];
	[locationManager release];
	[startingPoint release];
	[current_id release];
	[current_name release];
	[current_neighborhood release];
	[current_numMachines release];
	[current_lat release];
	[current_lon release];
	[current_numLocations release];
	[current_numLocations release];
	[current_isPrimary release];
	[current_shortName release];
	[allMachines release];
	[allLocations release];
	[controllers release];
	[tableTitles release];
	[super dealloc];
}

# pragma mark - 
# pragma mark Load Init XML

-(void)loadInitXML:(int)withID
{
	if(xmlStarted == YES) return;
	xmlStarted = YES;
	
	NSLog(@"--load init xml");
	
	initID = withID;
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	[self showLoaderIcon];
	
	NSString *path;
	switch (withID) {
		case 2:
			NSLog(@"Parsing Regions");
			path = [[NSString alloc] initWithFormat:@"http://pinballmap.com/iphone.html?init=2"];
			init2Loaded = YES;
			break;
		case 1:
		default:
			NSLog(@"Parsing Region %@", appDelegate.activeRegion.formalName);
			path = [[NSString alloc] initWithFormat:@"%@init=1",appDelegate.rootURL];
			break;
	}
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
	[pool release];
	[path release];
}



# pragma mark -
# pragma mark Location Manager

-(void)  locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
		    fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"**** LOCATION UPDATE ****");
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(appDelegate.userLocation != nil)
	{
		appDelegate.userLocation = nil;
		[appDelegate.userLocation release];
	}
	//appDelegate.userLocation = [[CLLocation alloc] initWithLatitude:32.78 longitude:-117.207];
	appDelegate.userLocation = newLocation;
	
	if(init2Loaded != YES)
	{
		init2Loaded = YES;
		[self loadInitXML:2];
	}
}


-(void)locationManager:(CLLocationManager *)manager
	  didFailWithError:(NSError *)error
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	

		[self.locationManager stopUpdatingLocation];
		[self.locationManager release];
		self.locationManager.delegate = nil;
		
		
		
		NSString *errorType = (error.code == kCLErrorDenied) ? @"Please Allow" : @"Unknown Error";
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:errorType
							  message:@"User Location denied, defaulting to static location."
							  delegate:self
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		appDelegate.userLocation = [[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785];
}

# pragma mark -
# pragma mark XML Parsing Stuff
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	
	currentElement = [elementName copy];
	
	switch (initID) {
		case 2:
			if ([elementName isEqualToString:@"region"])
			{
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
			if ([elementName isEqualToString:@"location"])
			{
				activeNode            = @"location";
				current_id            = [[NSMutableString     alloc] init];
				current_name          = [[NSMutableString     alloc] init];
				current_numMachines   = [[NSMutableString     alloc] init];
				current_lat           = [[NSMutableString     alloc] init];
				current_lon           = [[NSMutableString     alloc] init];
				current_neighborhood  = [[NSMutableString     alloc] init];
			}
			else if ([elementName isEqualToString:@"machine"])
			{
				activeNode            = @"machine";
				
				current_id            = [[NSMutableString     alloc] init];
				current_name          = [[NSMutableString     alloc] init];
				current_numLocations  = [[NSMutableString     alloc] init];
			}
			else if ([elementName isEqualToString:@"zone"])
			{
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
			if([activeNode isEqualToString:@"region"] && ![string isEqualToString:@"\n"])
			{
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
			if([activeNode isEqualToString:@"location"])
			{
				if ([currentElement isEqualToString:@"id"])           [current_id appendString:string];
				if ([currentElement isEqualToString:@"name"])         [current_name appendString:string];
				if ([currentElement isEqualToString:@"neighborhood"]) [current_neighborhood appendString:string];
				if ([currentElement isEqualToString:@"numMachines"])  [current_numMachines appendString:string];
				if ([currentElement isEqualToString:@"lat"])          [current_lat appendString:string];
				if ([currentElement isEqualToString:@"lon"])          [current_lon appendString:string];
			}
			else if([activeNode isEqualToString:@"machine"])
			{
				if ([currentElement isEqualToString:@"id"])           [current_id appendString:string];
				if ([currentElement isEqualToString:@"name"])         [current_name appendString:string];
				if ([currentElement isEqualToString:@"numLocations"]) [current_numLocations appendString:string];
			}
			else if([activeNode isEqualToString:@"zone"])
			{
				if ([currentElement isEqualToString:@"id"])           [current_id appendString:string];
				if ([currentElement isEqualToString:@"name"])         [current_name appendString:string];
				if ([currentElement isEqualToString:@"shortName"])    [current_shortName appendString:string];
				if ([currentElement isEqualToString:@"isPrimary"])    [current_isPrimary appendString:string];
			}
			break;
	}
	
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	
	//Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	switch (initID) {
		case 2:
			if ([elementName isEqualToString:@"region"])
			{
				RegionObject *regionobject = [[RegionObject alloc] init];
				regionobject.id_number  = current_id;
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
				[regionobject release];
				
				[current_id release];
				[current_name release];
				[current_formalName release];
				[current_lat release];
				[current_lon release];
				[current_subdir release];
			}
			
			break;
		default:
		case 1:
			if ([elementName isEqualToString:@"location"])
			{
				if([current_numMachines intValue] == 0)
				{
					NSLog(@"M - %@ - %@ has no machines.",current_id,current_name);
				}
				else
				{
					//NSLog(@"Building Location: %@",current_name);
					
					LocationObject *tempLocation = [[LocationObject alloc] init];
					
					double lon = [current_lon doubleValue];
					double lat = [current_lat doubleValue];
					
					if(lat == 0.0 || lon == 0.0)
					{
						NSLog(@"C - %@ - Missing Coords for %@",current_id,current_name);
						lat = 45.52295;
						lon = -122.66785;
					}
					
					//Set Distance
					CLLocation         *coords  = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
					/*CLLocationDistance  distance = [startingPoint getDistanceFrom:coords] / 1609.344;
					
					NSNumber          *distNum      = [[NSNumber alloc] initWithDouble:distance];
					NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
					[numberFormat setMinimumIntegerDigits:1];
					[numberFormat setMaximumFractionDigits:1];
					[numberFormat setMinimumFractionDigits:1];
					
					NSString *distanceString = [[NSString alloc] initWithFormat:@"%@ mi", [numberFormat stringFromNumber:distNum]];
					*/
					//Build Object
					tempLocation.id_number         = current_id;
					tempLocation.totalMachines     = [current_numMachines intValue];
					tempLocation.name              = current_name;
					tempLocation.neighborhood      = current_neighborhood;
					tempLocation.coords            = coords;
					[tempLocation updateDistance];
					//tempLocation.distance          = distance;
					//tempLocation.distanceRounded   = [[numberFormat stringFromNumber:distNum] doubleValue];
					//tempLocation.distanceString    = distanceString;
					
					if(allLocations == nil)
						allLocations = [[NSMutableDictionary alloc] init];
				
					//Store Location
					[allLocations setObject:tempLocation forKey:current_id];
					
					/*[distanceString release];
					[distNum release];
					[numberFormat release];*/
					[coords release];
					
					[tempLocation release];
				}
				
				[current_id release];
				[current_name release];
				[current_numMachines release];
				[current_lat release];
				[current_lon release];
				[current_neighborhood release];
			}
			else if ([elementName isEqualToString:@"machine"])
			{
				if([current_numLocations intValue] == 0)
				{
					NSLog(@"L - %@ - %@ has no locations.",current_id,current_name);
				}
				else
				{
					NSMutableDictionary *tempMachine = [[NSMutableDictionary alloc] init];
					[tempMachine setValue:current_id forKey:@"id"];
					[tempMachine setValue:current_name forKey:@"name"];
					[tempMachine setValue:current_numLocations forKey:@"numLocations"];
				
					if(allMachines == nil)
						allMachines  = [[NSMutableDictionary alloc] init];
					
					[allMachines setObject:tempMachine forKey:current_id];
					[tempMachine release];
					
				}
				
				[current_id release];
				[current_name release];
				[current_numLocations release];
			}
			else if ([elementName isEqualToString:@"zone"])
			{
				Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
				
				ZoneObject *zone = [[ZoneObject alloc] init];
				zone.name = current_name;
				zone.id_number = current_id;
				zone.shortName = current_shortName;
				zone.isPrimary = current_isPrimary;
				
				if(appDelegate.activeRegion.primaryZones == nil)  appDelegate.activeRegion.primaryZones = [[NSMutableArray alloc] init];
				if(appDelegate.activeRegion.secondaryZones == nil) appDelegate.activeRegion.secondaryZones = [[NSMutableArray alloc] init];
				
				//Add to Primary or Secondary Array
				if([zone.isPrimary isEqualToString:@"1"])
					[appDelegate.activeRegion.primaryZones addObject:zone];
				else
					[appDelegate.activeRegion.secondaryZones addObject:zone];
				
				[zone release];
				
				[current_id release];
				[current_name release];
				[current_shortName release];
				[current_isPrimary release];
			}
			break;
	}
	
	//[currentElement release];
	currentElement = @"";
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
	switch (initID) {
		case 2:
			
			NSLog(@"init=2 done");
			//set active region
			appDelegate.regions = tempRegionArray;
			
			//Find Closest Region
			RegionObject       *closestRegion   = [appDelegate.regions objectAtIndex:1];
			CLLocationDistance  closestDistance = 24901.55;
			for (int i = 0; i < [appDelegate.regions count]; i++)
			{
				RegionObject *reg = [appDelegate.regions objectAtIndex:i];
				
				double lon = [reg.lon doubleValue];
				double lat = [reg.lat doubleValue];
				
				NSLog(@"Region %@ - (%d,%d)",reg.formalName,lat,lon);
				
				//Set Distance
				CLLocation         *coords  = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
				CLLocationDistance  distance = [appDelegate.userLocation getDistanceFrom:coords] / 1609.344;
				
				if(closestDistance > distance)
				{
					NSLog(@"new reg",reg.formalName,lat,lon);
					closestRegion   = reg;
					closestDistance = distance;
				}
				[coords release];
			}
			
			[appDelegate newActiveRegion:closestRegion];
			[appDelegate showSplashScreen];
			
			//Set Title
			self.title = [NSString stringWithFormat:@"%@ Pinball Map",appDelegate.activeRegion.name];

			[tempRegionArray release];
						
			//now load init=1
			xmlStarted = NO;
			//[self loadInitXML:1];
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[self performSelectorInBackground:@selector(loadInitXML:) withObject:nil];
			[pool release];
			
			break;
		default:
		case 1:
			//[self.locationManager stopUpdatingLocation];
			/*[self.locationManager release];
			self.locationManager.delegate = nil;*/
			
			appDelegate.activeRegion.machines  = self.allMachines;
			appDelegate.activeRegion.locations = self.allLocations;
			
			if(self.controllers == nil)
			{
				//Controller Array
				NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:6];
				
				//Locations
				ZonesViewController *locView = [[ZonesViewController alloc] initWithStyle:UITableViewStylePlain];
				locView.title = @"Locations";
				[array addObject:locView];
				[locView release];
				
				//Lookup by Machine
				MachineViewController *machView = [[MachineViewController alloc] initWithStyle:UITableViewStylePlain];
				//MachineViewController *machView = [[MachineViewController alloc] initWithNibName:@"XMLTableView" bundle:nil];
				machView.title = @"Machines";
				[array addObject:machView];
				[machView release];
				
				//Closest Locations
				ClosestLocations *closest = [[ClosestLocations alloc] initWithStyle:UITableViewStylePlain];
				closest.title = @"Closest Locations";
				[array addObject:closest];
				[closest release];
				
				//RSS Feed
				RSSViewController *rssView = [[RSSViewController alloc] initWithStyle:UITableViewStylePlain];
				rssView.title = @"Recently Added";
				[array addObject:rssView];
				[rssView release];
				
				//RSS Feed
				EventsViewController *eventView = [[EventsViewController alloc] initWithStyle:UITableViewStylePlain];
				eventView.title = @"Events";
				[array addObject:eventView];
				[eventView release];
				
				//Change Region
				RegionSelectViewController *regionselect = [[RegionSelectViewController alloc] initWithStyle:UITableViewStylePlain];
				regionselect.title = @"Change Region";
				[array addObject:regionselect];
				[regionselect release]; 
				
				self.controllers = array;
				[array release];
			}
			
			NSLog(@"Parser Did End Document!");
			[appDelegate hideSplashScreen];
			[self.tableView reloadData];
			[self hideLoaderIcon];
			
			//UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
			//accel.delegate = self;
			//accel.updateInterval = (1.0f/10.0f);
			
			break;
	}
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	if(parsingAttempts < 15)
	{
		parsingAttempts ++;
		
		if(initID == 1)
		{
			[allLocations release];
			[allMachines release];
			
			allLocations = [[NSMutableDictionary alloc] init];
			allMachines  = [[NSMutableDictionary alloc] init];
		}
		else if(initID == 2)
		{
			[tempRegionArray release];
			tempRegionArray = nil;
		}

		xmlStarted = NO;
		
		[self loadInitXML:initID];
		
	}
	else
	{
		[self hideLoaderIcon];

		NSString *errorType = [[NSString alloc] initWithString:@"Please close the app and try again."];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"No Internet Connection Found"
							  message:errorType
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[errorType release];
	}	
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [controllers count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SingleTextID";
    
    PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getTableCell];
	}
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	//UITableViewController *controller = [controllers objectAtIndex:row];
	//cell.nameLabel.text = controller.title;
	cell.nameLabel.text = [tableTitles objectAtIndex:row];
	return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	//if(xmlStarted) return;
	NSLog(@"selected machine:");
	NSUInteger row = [indexPath row];
	UITableViewController *nextController = [self.controllers objectAtIndex:row];
	[self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark -
#pragma mark Alert View Delegate 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"alert view %i:",buttonIndex);
	
	if(buttonIndex == 0)
		[self loadInitXML:2];
}

# pragma mark -
# pragma mark Press Info Button
-(void)pressInfo:(id)sender
{
	if(aboutView == nil)
	{
		aboutView = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
		aboutView.title = @"About";
	}
	
	[self.navigationController pushViewController:aboutView animated:YES];
}

@end

