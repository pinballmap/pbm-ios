#import "Utils.h"
#import "Machine.h"
#import "MachineFilterView.h"
#import "MachineViewController.h"

@implementation MachineViewController
@synthesize machinesByFirstLetter, keys;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:@"Machines"];
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	machinesByFirstLetter = [[NSMutableDictionary alloc] init];
	
	for (Machine *machine in appDelegate.activeRegion.machines) {
		NSString *firstLetter = [Utils directoryFirstLetter:machine.name];
        
        NSMutableArray *letterArray = [machinesByFirstLetter objectForKey:firstLetter];
        if (letterArray == nil) {
            letterArray = [[NSMutableArray alloc] init];
            [machinesByFirstLetter setObject:letterArray forKey:firstLetter];
        }
			
        [letterArray addObject:machine];
	}
    
    for (NSString *key in machinesByFirstLetter.allKeys) {    
        NSMutableArray *machines = [machinesByFirstLetter objectForKey:key];
        machines = (NSMutableArray *)[machines sortedArrayUsingComparator:^NSComparisonResult(Machine *a, Machine *b) {
            return [a.name compare:b.name];
        }];
        
        [machinesByFirstLetter setObject:machines forKey:key];
    }
	
	[self setKeys:[[machinesByFirstLetter allKeys] sortedArrayUsingSelector:@selector(compare:)]];
	
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	NSDictionary *nameSection = [machinesByFirstLetter objectForKey:key];
    
    return [nameSection count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [keys objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return keys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBMTableCell *cell = (PBMTableCell*)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
    if (cell == nil) {
		cell = [self getTableCell];
    }
    
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray *)[machinesByFirstLetter objectForKey:keyAtSection];
	Machine *machine = [letterArray objectAtIndex:[indexPath row]];
	[cell.nameLabel setText:machine.name];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MachineFilterView *machineFilterView = [[MachineFilterView alloc] initWithStyle:UITableViewStylePlain];
	
	NSString *keyAtSection = [keys objectAtIndex:[indexPath section]];
	NSArray *letterArray = (NSArray *)[machinesByFirstLetter objectForKey:keyAtSection];
	Machine *machine = [letterArray objectAtIndex:[indexPath row]];
	[machineFilterView setMachine:machine];
    
	[self.navigationController pushViewController:machineFilterView animated:YES];
}

@end