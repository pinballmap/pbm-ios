#import "ZonesViewController.h"
#import "Zone.h"

@implementation ZonesViewController
@synthesize zones, titles, locationFilter;

- (void)viewWillAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSArray *allZones = [[NSArray alloc] initWithObjects:@"All", appDelegate.activeRegion.machineFilterString, @"< 1 mile", nil];
	NSArray *primaryZones = [[NSArray alloc] initWithArray:appDelegate.activeRegion.primaryZones];
	NSArray *secondaryZones = [[NSArray alloc] initWithArray:appDelegate.activeRegion.secondaryZones];
	NSString *regionTitle = appDelegate.activeRegion.formalName;
	
	zones = [[NSDictionary alloc] initWithObjectsAndKeys:secondaryZones, @"Suburbs", primaryZones, regionTitle, allZones, @"Filter by", nil];
	titles = [[NSArray alloc] initWithObjects:@"Filter by", regionTitle, @"Suburbs", nil];
	
	[self setTitle:@"Locations"];
	
	if(locationFilter != nil)
		[locationFilter setCurrentZoneID:@" "];
	
	[self.tableView reloadData];
	
	[super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [zones count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *zonesForSection = (NSArray *)[zones objectForKey:keyAtSection];
    
	return [zonesForSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
    PBMTableCell *cell = (PBMTableCell *)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
    if (cell == nil) {
		cell = [self getTableCell];
    }
    
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *zonesForSection = (NSArray *)[zones objectForKey:keyAtSection];
	
	if(section == 0) {
		[cell.nameLabel setText:[zonesForSection objectAtIndex:row]];
	} else {
		Zone *zone = (Zone *)[zonesForSection objectAtIndex:row];
		[cell.nameLabel setText:zone.name];
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
	NSArray *zonesForSection = (NSArray *)[zones objectForKey:keyAtSection];
	
	if(section == 0) {
		[locationFilter setZoneID:[zonesForSection objectAtIndex:row]];
	} else {
		Zone *zone = (Zone *)[zonesForSection objectAtIndex:row];
        
		[locationFilter setZoneID:zone.name];
		[locationFilter setTheNewZone:zone];
	}
	
	[self.navigationController pushViewController:locationFilter animated:YES];	
}

@end