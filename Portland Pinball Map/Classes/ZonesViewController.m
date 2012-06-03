#import "ZonesViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "ZoneObject.h"

@implementation ZonesViewController
@synthesize zones, titles, locationFilter;

- (void)viewWillAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"Zones View Controller Load %@",appDelegate.activeRegion);
	
	NSArray *array1 = [[NSArray alloc] initWithObjects:@"All",appDelegate.activeRegion.machineFilterString,@"< 1 mile",nil];
	NSArray *array2 = [[NSArray alloc] initWithArray:appDelegate.activeRegion.primaryZones];
	NSArray *array3 = [[NSArray alloc] initWithArray:appDelegate.activeRegion.secondaryZones];
	
	NSString *regionTitle = [NSString stringWithString:appDelegate.activeRegion.name];
	
    
	zones = [[NSDictionary alloc] initWithObjectsAndKeys:array3,@"Suburbs",array2,regionTitle,array1,@"Filter by",nil];
	titles = [[NSArray alloc] initWithObjects:@"Filter by",regionTitle,@"Suburbs",nil];
	
	
	self.title = @"Locations";
	
	if(locationFilter != nil)
		locationFilter.currentZoneID = @" ";
	
	[self.tableView reloadData];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	[super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [zones count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *array = (NSArray*)[zones objectForKey:keyAtSection];
	return [array count];
}

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
	
	if(section == 0) {
		cell.nameLabel.text = [array objectAtIndex:row];
	} else {
		ZoneObject *zone = (ZoneObject*)[array objectAtIndex:row];
		cell.nameLabel.text = [[NSString alloc] initWithString:zone.name];
	}

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	return [titles objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(locationFilter == nil) {
		locationFilter = [[LocationFilterView alloc] initWithStyle:UITableViewStylePlain];
	}
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *array = (NSArray*)[zones objectForKey:keyAtSection];
	
	if(section == 0) {
		locationFilter.zoneID = [array objectAtIndex:row];
	} else {
		ZoneObject *zone = (ZoneObject*)[array objectAtIndex:row];
		NSString *newString = [[NSString alloc] initWithString:zone.name];
		locationFilter.zoneID = newString;
		locationFilter.theNewZone = zone;
	}
	
	[self.navigationController pushViewController:locationFilter  animated:YES];	
}


@end