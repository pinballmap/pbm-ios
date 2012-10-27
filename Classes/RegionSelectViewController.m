#import "Region.h"
#import "RequestPage.h"
#import "RegionSelectViewController.h"

@implementation RegionSelectViewController

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:@"Change Region"];
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [appDelegate.regions count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBMTableCell *cell = (PBMTableCell *)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
    
    if (cell == nil) {
		cell = [self getTableCell];
    }
	
	if (indexPath.row >= [appDelegate.regions count]) {
		[cell.nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
		[cell.nameLabel setText:@"*Request Your Region"];
	} else {
		Region *region = [appDelegate.regions objectAtIndex:indexPath.row];
		[cell.nameLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[cell.nameLabel setText:region.formalName];        
	}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (indexPath.row >= [appDelegate.regions count]) {
        RequestPage *requestPage = [[RequestPage alloc] initWithNibName:@"RequestPage" bundle:nil];
        [requestPage setTitle:@"Request Your Region"];
		
		[self.navigationController pushViewController:requestPage animated:YES];
	} else {
		[appDelegate setActiveRegion:appDelegate.regions[indexPath.row]];
		[self.navigationController popViewControllerAnimated:YES];
	}	
}

@end