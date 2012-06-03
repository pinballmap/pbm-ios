#import "RegionSelectViewController.h"
#import "RegionObject.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation RegionSelectViewController
@synthesize regionArray, requestPage;

- (void)viewWillAppear:(BOOL)animated {
	self.title = @"Change Region";
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	[super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    return [appDelegate.regions count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"SingleTextID";
    PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getTableCell];
    }
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(indexPath.row >= [appDelegate.regions count]) {
		cell.nameLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.nameLabel.text = @"*Request Your Region";
	} else {
		RegionObject *reg = [appDelegate.regions objectAtIndex:indexPath.row];
		cell.nameLabel.font = [UIFont boldSystemFontOfSize:20];
		cell.nameLabel.text = [NSString stringWithString:reg.formalName];

	}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(indexPath.row >= [appDelegate.regions count]) {
		if(requestPage == nil) {
			requestPage = [[RequestPage alloc] initWithNibName:@"RequestPage" bundle:nil];
			requestPage.title = @"Request Your Region";
		}
		
		[self.navigationController pushViewController:requestPage animated:YES];
	} else {
		[appDelegate newActiveRegion:[appDelegate.regions objectAtIndex:indexPath.row]];
		[self.navigationController popViewControllerAnimated:YES];
	}	
}


@end