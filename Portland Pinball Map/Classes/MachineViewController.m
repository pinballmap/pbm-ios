#import "MachineViewController.h"
#import "Utils.h"

@implementation MachineViewController
@synthesize sortedMachines, keys, machineFilter;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:@"Machines"];
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sortedMachines = [[NSMutableDictionary alloc] init];
	
	for (id key in appDelegate.activeRegion.machines) {
		NSDictionary *machine = [appDelegate.activeRegion.machines valueForKey:key];
		NSString *machineName = [machine valueForKey:@"name"];
		
		NSString *firstLetter = [Utils directoryFirstLetter:machineName];
        
		NSRange range = [machineName rangeOfString:@"no more pinball"];		
		if (range.length == 0) {
			NSMutableArray *letterArray = [sortedMachines objectForKey:firstLetter];
			if (letterArray == nil) {
				NSMutableArray *newLetterArray = [[NSMutableArray alloc] init];
				[sortedMachines setObject:newLetterArray forKey:firstLetter];
				letterArray = newLetterArray;
			}
			
			[letterArray addObject:machine];
		}
	}
	
	[self setKeys:[[sortedMachines allKeys] sortedArrayUsingSelector:@selector(compare:)]];
	
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
	return [keys objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return keys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"SingleTextID";
    PBMTableCell *cell = (PBMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getTableCell];
    }
    
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray*)[sortedMachines objectForKey:keyAtSection];
	NSDictionary *machine = [letterArray objectAtIndex:[indexPath row]];
	[cell.nameLabel setText:[machine objectForKey:@"name"]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(machineFilter == nil) {
		machineFilter = [[MachineFilterView alloc] initWithStyle:UITableViewStylePlain];
	}
	
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray*)[sortedMachines objectForKey:keyAtSection];
	NSDictionary *machine = [letterArray objectAtIndex:[indexPath row]];
	[machineFilter setMachineName:[machine objectForKey:@"name"]];
	[machineFilter setMachineID:[machine objectForKey:@"id"]];
    
	[self.navigationController pushViewController:machineFilter animated:YES];
}

@end