//
//  MachineFilterView.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MachineFilterView.h"
#import "LocationProfileViewController.h"
#import "RootViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"


@implementation MachineFilterView
@synthesize locationArray;
@synthesize machineID;
@synthesize machineName;
@synthesize temp_location_id;
@synthesize mapView;
@synthesize resetNavigationStackOnLocationSelect;
@synthesize noLocationsLabel;
@synthesize tempLocationArray;
@synthesize didAbortParsing;

-(void)viewDidLoad
{
	noLocationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
	noLocationsLabel.text = @"(no locations)";
	noLocationsLabel.backgroundColor = [UIColor blackColor];
	noLocationsLabel.textColor       = [UIColor whiteColor];
	noLocationsLabel.font            = [UIFont boldSystemFontOfSize:20];
	noLocationsLabel.textAlignment   = UITextAlignmentCenter;
	
	[super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.title = machineName;
	
	if(appDelegate.activeRegion.loadedMachines == nil)
	{
		appDelegate.activeRegion.loadedMachines = [[NSMutableDictionary alloc] init];
	}
	
	locationArray = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:machineID];
	
	NSLog(@"location array: %@", locationArray);
	
	self.tableView.contentOffset = CGPointZero;
	
	
	[self reloadLocationData];
	[super viewWillAppear:animated];

}	


- (void)viewDidAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (locationArray == nil) {
		
		didAbortParsing = NO;
		
		if(tempLocationArray != nil)
		{
			tempLocationArray = nil;
			[tempLocationArray release];
		}
		tempLocationArray = [[NSMutableArray alloc] init];
		
		NSString *url = [[NSString alloc] initWithFormat:@"%@get_machine=%@",appDelegate.rootURL,machineID];
		//locationArray = [[NSMutableArray alloc] init];
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:url];
		[pool release];
		[url release];
	}
	
	[super viewDidAppear:animated];
	
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (isParsing == YES)
	{
		NSLog(@"Parsing Aborted");
		didAbortParsing = YES;
		[tempLocationArray release];
		//[xmlParser abortParsing];
		//isParsing = NO;
	}
	
	[super viewWillDisappear:animated];
}

-(void) viewDidUnload
{
	noLocationsLabel = nil;
}

- (void)dealloc
{
	[tempLocationArray release];
	[noLocationsLabel release];
	[locationArray release];
	[machineID release];
	[machineName release];
	[temp_location_id release];
    [super dealloc];
}


# pragma mark -
# pragma mark Map Press


-(void)onMapPress:(id)sender
{
	if(mapView == nil)
	{
		mapView = [[LocationMap alloc] init];
		mapView.showProfileButtons = YES;
	}
	
	mapView.locationsToShow = locationArray;
	mapView.title = self.title;
	
	/*
	if (NO)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 1];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
		[self.navigationController pushViewController:mapView animated:YES];
		[UIView commitAnimations];	
	}
	else */
	[self.navigationController pushViewController:mapView animated:YES];
}



# pragma mark -
# pragma mark XML Parsing



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"id"])
	{
		temp_location_id = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if ([currentElement isEqualToString:@"id"]) [temp_location_id appendString:string];
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	
	NSLog(@"didEndElement: %@",elementName);
	if(didAbortParsing == YES) return;
	
	//Add in Location object based on loc id
	currentElement = @"";
	
	if ([elementName isEqualToString:@"id"])
	{
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		LocationObject *location = (LocationObject *)[appDelegate.activeRegion.locations objectForKey:temp_location_id];
		if(location != nil)
		{
			[location updateDistance];
			[tempLocationArray addObject:location];
		}
		else 
			NSLog(@"MachineFilterView: location id '%@' not found",temp_location_id);
		
		//[temp_location_id release]; //crashing app
	}
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	NSLog(@"parserDidEndDocument");
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(didAbortParsing == NO)
	{
		locationArray = tempLocationArray;
		[appDelegate.activeRegion.loadedMachines setObject:locationArray forKey:machineID];	
		[tempLocationArray release];
		[self reloadLocationData];
	}
	
	
	
	[super parserDidEndDocument:parser];
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[super parser:parser parseErrorOccurred:parseError];
	[self reloadLocationData];
}

#pragma mark -
#pragma mark Reload Location Data
-(void)reloadLocationData
{
	NSLog(@"reloadLocationData");
	
	if (locationArray == nil)
	{
		[noLocationsLabel removeFromSuperview];
		[self showLoaderIconLarge];
		
		self.navigationItem.rightBarButtonItem = nil;
	}
	else if ([locationArray count] == 0)
	{
		self.tableView.separatorColor = [UIColor blackColor];
		[self.view addSubview:noLocationsLabel];
		self.navigationItem.rightBarButtonItem = nil;
	}
	else
	{
		self.tableView.separatorColor = [UIColor darkGrayColor];
		[noLocationsLabel removeFromSuperview];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapPress:)] autorelease];
		
		NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)] autorelease];
		for(int i = 0 ; i < [locationArray count]; i++)
		{
			LocationObject *locobj = (LocationObject *)[locationArray objectAtIndex:i];
			[locobj updateDistance];
		}
		[locationArray sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
		
	
	}
	
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	    return [locationArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PPMDoubleTableCell *cell = (PPMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
		cell = [self getDoubleCell];
    }
    
	NSUInteger row = [indexPath row];
	LocationObject *location = [locationArray objectAtIndex:row];
	cell.nameLabel.text = location.name;
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	cell.subLabel.text = (appDelegate.showUserLocation == YES) ? location.distanceString : @"";
	//cell.subLabel.text = location.distanceString;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSUInteger row = [indexPath row];
	LocationObject *location = [locationArray objectAtIndex:row];
	
	if(NO)
	//if(resetNavigationStackOnLocationSelect == YES)
	{
		NSLog(@"resetNavigationStack!");
		RootViewController *rootController = (RootViewController *)[self.navigationController.viewControllers objectAtIndex:0];
		LocationProfileViewController *locationProfileView = [self getLocationProfile];
		
		locationProfileView.showMapButton = YES;
		locationProfileView.activeLocationObject = location;
		
		
		NSArray *quickArray = [[NSArray alloc] initWithObjects:rootController,self,locationProfileView,nil];
		[self.navigationController setViewControllers:quickArray animated:NO];
		[quickArray release];
	}
	else
	{
		[self showLocationProfile:location  withMapButton:YES];
	}
	
}

@end
