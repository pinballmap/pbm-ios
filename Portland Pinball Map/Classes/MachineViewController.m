#import "MachineViewController.h"

@implementation MachineViewController
@synthesize sortedMachines, keys, machineFilter;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = @"Machines";
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
	sortedMachines = [[NSMutableDictionary alloc] init];
	
	for(id key in appDelegate.activeRegion.machines) {
		NSDictionary *machine = [appDelegate.activeRegion.machines valueForKey:key];
		NSString *machineName = [machine valueForKey:@"name"];
		
		NSString *firstLetter = [[NSString alloc] initWithString:[[machineName substringToIndex:1] lowercaseString]];
		
		NSString *noMorePin = [[NSString alloc] initWithString:@"no more pinball"];
		NSRange range = [machineName rangeOfString:noMorePin];
		
		if (range.length == 0) {
			NSString *searchString = [[NSString alloc] initWithString:@"abcdefghijklmnopqrstuvwxyz"];
			NSRange letterRange = [searchString rangeOfString:firstLetter];
			if (letterRange.length == 0) {
				firstLetter = [[NSString alloc] initWithString:@"#"];
			}		
			
			NSMutableArray *letterArray = [sortedMachines objectForKey:firstLetter];
			if(letterArray == nil) {
				NSMutableArray *newLetterArray = [[NSMutableArray alloc] init];
				[sortedMachines setObject:newLetterArray forKey:firstLetter];
				letterArray = newLetterArray;
			}
			
			[letterArray addObject:machine];
			
		}
	}
	
	for(id key in sortedMachines) {
		NSMutableArray *orig_array = [sortedMachines objectForKey:key];
		NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)];
		[orig_array sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	}
	
	NSArray *array = [[sortedMachines allKeys] sortedArrayUsingSelector:@selector(compare:)];
	self.keys = array;
	
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	NSDictionary *nameSection = [sortedMachines objectForKey:key];
    
    return [nameSection count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	return key;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return keys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"SingleTextID";
    PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getTableCell];
    }
    
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [keys objectAtIndex:section];
	NSArray *letterArray = (NSArray*)[sortedMachines objectForKey:keyAtSection];
	NSDictionary *machine = [letterArray objectAtIndex:row];
	cell.nameLabel.text = [machine objectForKey:@"name"];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(machineFilter == nil) {
		machineFilter = [[MachineFilterView alloc] initWithStyle:UITableViewStylePlain];
	}
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *keyAtSection = [keys objectAtIndex:section];
	NSArray *letterArray = (NSArray*)[sortedMachines objectForKey:keyAtSection];
	NSDictionary *machine = [letterArray objectAtIndex:row];
	
	machineFilter.machineName = [machine objectForKey:@"name"];
	machineFilter.machineID = [machine objectForKey:@"id"];
	[self.navigationController pushViewController:machineFilter  animated:YES];
}

@end