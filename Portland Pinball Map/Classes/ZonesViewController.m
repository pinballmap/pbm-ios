//
//  ZonesViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZonesViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "ZoneObject.h"


@implementation ZonesViewController
@synthesize zones;
@synthesize titles;
@synthesize locationFilter;

- (void)viewDidLoad
{	
	[super viewDidLoad];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"Zones View Controller Load %@",appDelegate.activeRegion);
	
	NSArray *array1 = [[NSArray alloc] initWithObjects:@"All",appDelegate.activeRegion.machineFilterString,@"< 1 mile",nil];
	NSArray *array2 = [[NSArray alloc] initWithArray:appDelegate.activeRegion.primaryZones]; //[[NSArray alloc] initWithObjects:@"Downtown",@"North",@"Northeast",@"Northwest",@"Southeast",@"Southwest",nil];
	NSArray *array3 = [[NSArray alloc] initWithArray:appDelegate.activeRegion.secondaryZones]; //[[NSArray alloc] initWithObjects:@"Beaverton",@"Hillsboro",@"Tigard",nil];
	
	NSString *regionTitle = [NSString stringWithString:appDelegate.activeRegion.name];
	
	if(zones != nil) [zones release];
	if(titles != nil) [titles release];
	zones = [[NSDictionary alloc] initWithObjectsAndKeys:array3,@"Suburbs",array2,regionTitle,array1,@"Filter by",nil];
	titles = [[NSArray alloc] initWithObjects:@"Filter by",regionTitle,@"Suburbs",nil];
	
	[array1 release];
	[array2 release];
	[array3 release];
	
	self.title = @"Locations";
	
	if(locationFilter != nil)
		locationFilter.currentZoneID = @" ";
	
	[self.tableView reloadData];
	
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.title = @"back";
	[super viewWillDisappear:animated];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [zones count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *array = (NSArray*)[zones objectForKey:keyAtSection];
	return [array count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"SingleTextID";
    PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getTableCell];
    }
    
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *array = (NSArray*)[zones objectForKey:keyAtSection];
	
	if(section == 0)
	{
		cell.nameLabel.text = [array objectAtIndex:row];
	}
	else
	{
		ZoneObject *zone = (ZoneObject*)[array objectAtIndex:row];
		cell.nameLabel.text = [[[NSString alloc] initWithString:zone.name] autorelease];
	}

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	NSString *key = [titles objectAtIndex:section];
	return key;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
	if(locationFilter == nil)
	{
		locationFilter = [[LocationFilterView alloc] initWithStyle:UITableViewStylePlain];
	}
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *array = (NSArray*)[zones objectForKey:keyAtSection];
	
	if(section == 0)
	{
		locationFilter.zoneID = [array objectAtIndex:row];
	}
	else
	{
		ZoneObject *zone = (ZoneObject*)[array objectAtIndex:row];
		NSString *newString = [[NSString alloc] initWithString:zone.name];
		locationFilter.zoneID = newString;
		[newString release];
		locationFilter.newZone = zone;
	}
	
	[self.navigationController pushViewController:locationFilter  animated:YES];	
}

- (void)dealloc {
	[titles release];
	[zones release];
	[locationFilter release];
    [super dealloc];
}


@end

