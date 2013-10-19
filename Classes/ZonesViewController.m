#import "Zone.h"
#import "ZonesViewController.h"
#import "LocationFilterView.h"

@implementation ZonesViewController
@synthesize zones, titles;

- (void)viewWillAppear:(BOOL)animated {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSArray *allZones = @[@"All", appDelegate.activeRegion.formattedNMachines, @"< 1 mile"];
	NSArray *primaryZones = [[NSArray alloc] initWithArray:appDelegate.activeRegion.primaryZones];
	NSArray *secondaryZones = [[NSArray alloc] initWithArray:appDelegate.activeRegion.secondaryZones];
	NSString *regionTitle = appDelegate.activeRegion.formalName;
	
	zones = @{@"Suburbs": secondaryZones, regionTitle: primaryZones, @"Filter by": allZones};
	titles = @[@"Filter by", regionTitle, @"Suburbs"];
	
	[self setTitle:@"Locations"];
	
	[self.tableView reloadData];
	
    if (appDelegate.isPad) {
        [appDelegate.locationMap setLocationsToShow:appDelegate.activeRegion.locations.allObjects];
        [appDelegate.locationMap loadPins];
    }
    
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
    
	LocationFilterView *locationFilterView = [[LocationFilterView alloc] initWithStyle:UITableViewStylePlain];
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [titles objectAtIndex:section];
	NSArray *zonesForSection = (NSArray *)[zones objectForKey:keyAtSection];
	
	if(section == 0) {
		[locationFilterView setZoneID:[zonesForSection objectAtIndex:row]];
	} else {
		Zone *zone = (Zone *)[zonesForSection objectAtIndex:row];
		[locationFilterView setZoneID:zone.name];
		[locationFilterView setTheNewZone:zone];
	}
	
	[self.navigationController pushViewController:locationFilterView animated:YES];	
}

@end