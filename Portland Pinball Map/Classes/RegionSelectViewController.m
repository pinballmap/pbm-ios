#import "RegionSelectViewController.h"
#import "Region.h"

@implementation RegionSelectViewController
@synthesize regionArray, requestPage;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:@"Change Region"];
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [appDelegate.regions count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"SingleTextID";
    PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getTableCell];
    }
	
	if(indexPath.row >= [appDelegate.regions count]) {
		[cell.nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
		[cell.nameLabel setText:@"*Request Your Region"];
	} else {
		Region *reg = [appDelegate.regions objectAtIndex:indexPath.row];
		[cell.nameLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[cell.nameLabel setText:reg.formalName];
	}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	if(indexPath.row >= [appDelegate.regions count]) {
		if(requestPage == nil) {
			requestPage = [[RequestPage alloc] initWithNibName:@"RequestPage" bundle:nil];
			[requestPage setTitle:@"Request Your Region"];
		}
		
		[self.navigationController pushViewController:requestPage animated:YES];
	} else {
		[appDelegate setActiveRegion:[appDelegate.regions objectAtIndex:indexPath.row]];
		[self.navigationController popViewControllerAnimated:YES];
	}	
}

@end