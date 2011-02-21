//
//  LocationFilterView.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationFilterView.h"

@implementation LocationFilterView
@synthesize filteredLocations;
@synthesize keys;
@synthesize mapView;
@synthesize locationArray;
@synthesize zoneID;
@synthesize newZone;
@synthesize currentZone;
@synthesize currentZoneID;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style])
	{
		
    }
    return self;
}


- (void)viewDidLoad {
	
	emptyArray = [[NSArray alloc] init];
	
	//UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	//[mapButton addTarget:self action:@selector(onMapPress:) forControlEvents:UIControlEventTouchUpInside];
	//self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:mapButton] autorelease];
		
    [super viewDidLoad];
	
		//rootView = (RootViewController *) [[self.navigationController viewControllers] objectAtIndex:0];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated
{
	if(![zoneID isEqualToString:currentZoneID])
	{
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		self.tableView.contentOffset = CGPointZero;
		
		totalLocations    = 0;
		filteredLocations = [[NSMutableDictionary alloc] init];
		locationArray     = [[NSMutableArray alloc] init];
		
		for(id key in appDelegate.activeRegion.locations)
		{
			LocationObject *location = [appDelegate.activeRegion.locations valueForKey:key];
			NSString *neighborhood = location.neighborhood;
			
			//All Filter
			if([zoneID isEqualToString:@"All"]) [self addToFilterDictionary:location];
			
			else if([zoneID isEqualToString:@"< 1 mile"] && appDelegate.showUserLocation == YES)
			{
				[location updateDistance];
				if(location.distanceRounded <= 1.0) [self addToFilterDictionary:location];
			}
			//3+ Machines
			else if([zoneID isEqualToString:appDelegate.activeRegion.machineFilterString])
			{
				NSInteger numMachines = location.totalMachines;
				if(numMachines >= [appDelegate.activeRegion.machineFilter intValue]) [self addToFilterDictionary:location];
				
			}
			/*
			//4+ Machines
			else if([zoneID isEqualToString:@"4+ Machines"])
			{
				//NSInteger numMachines = [[location objectForKey:@"numMachines"] intValue];
				NSInteger numMachines = location.totalMachines;
				if(numMachines >= 4) [self addToFilterDictionary:location];
				
			}*/
			else if([neighborhood isEqualToString:newZone.shortName]) [self addToFilterDictionary:location];
		
			/*//By Neighborhood
			else if([zoneID isEqualToString:@"Downtown"]   && [neighborhood isEqualToString:@"dt"]) [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"North"]      && [neighborhood isEqualToString:@"n"])  [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"Northwest"]  && [neighborhood isEqualToString:@"nw"]) [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"Northeast"]  && [neighborhood isEqualToString:@"ne"]) [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"Southwest"]  && [neighborhood isEqualToString:@"sw"]) [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"Southeast"]  && [neighborhood isEqualToString:@"se"]) [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"Beaverton"]  && [neighborhood isEqualToString:@"bv"]) [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"Hillsboro"]  && [neighborhood isEqualToString:@"hb"]) [self addToFilterDictionary:location];
			else if([zoneID isEqualToString:@"Tigard"]     && [neighborhood isEqualToString:@"tg"]) [self addToFilterDictionary:location];
			*/
		}
		
		for(id key in filteredLocations)
		{
			NSMutableArray *orig_array = [filteredLocations objectForKey:key];
			NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)] autorelease];
			[orig_array sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
		}
		
		headerHeight = (totalLocations > 25) ? 20 : 0;
		
		NSArray *array = [[filteredLocations allKeys] sortedArrayUsingSelector:@selector(compare:)];
		self.keys = array;
		
		[self.tableView reloadData];
	}
	else 
	{
		NSLog(@"same title");
	}
	
	if(currentZoneID != nil) [currentZoneID release];
	currentZoneID = [[NSString alloc] initWithString:zoneID];
	
	NSString *newTitle;
	if([zoneID isEqualToString:@"All"])
		newTitle = [[NSString alloc] initWithString:@"All Locations"];
	else
		newTitle = [[NSString alloc] initWithFormat:@"%@", zoneID];
	
	self.title = newTitle;
	[newTitle release];
	
	if ([keys count] > 0)
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onMapPress:)] autorelease];
	else 
		self.navigationItem.rightBarButtonItem = nil;
	
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.title = @"back";
	[super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(void) addToFilterDictionary:(LocationObject *)location
{
	totalLocations ++;
	//NSString *locationName = [location valueForKey:@"name"];
	NSString *locationName = location.name;
	NSString *firstLetter = [[NSString alloc] initWithString:[[locationName substringToIndex:1] lowercaseString]];
	
	//Check For Number
	NSString *searchString = [[NSString alloc] initWithString:@"abcdefghijklmnopqrstuvwxyz"];
	NSRange letterRange = [searchString rangeOfString:firstLetter];
	if (letterRange.length == 0) 
	{
		[firstLetter release];
		firstLetter = [[NSString alloc] initWithString:@"#"];
	}
	
	
	NSMutableArray *letterArray = [filteredLocations objectForKey:firstLetter];
	if(letterArray == nil)
	{
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

-(void)onMapPress:(id)sender
{
	if(mapView == nil)
	{
		mapView = [[LocationMap alloc] init];
		mapView.showProfileButtons = YES;
	}
	
	mapView.locationsToShow = locationArray;
	mapView.title = self.title;
	
	if (NO)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 1];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
		[self.navigationController pushViewController:mapView animated:YES];
		[UIView commitAnimations];	
	}
	else
		[self.navigationController pushViewController:mapView animated:YES];
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil
	[emptyArray release];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	NSDictionary *nameSection = [filteredLocations objectForKey:key];
    return [nameSection count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	NSString *key = [keys objectAtIndex:section];
	return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	//if(headerHeight > 0) return alphabet;
	if(headerHeight > 0) return keys;
	
	return emptyArray;
}


// Customize the appearance of table view cells.
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
	//NSDictionary *location = [letterArray objectAtIndex:row];
	//cell.nameLabel.text = [location objectForKey:@"name"];
	//cell.subLabel.text = [location objectForKey:@"distance"];
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc 
{
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

