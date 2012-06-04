#import "BlackTableViewController.h"
#import "LocationProfileViewController.h"

@implementation BlackTableViewController
@synthesize headerHeight, activityView, loadingLabel;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityView setFrame:CGRectMake(70,130,30,30)];
	[self.view addSubview:activityView];
	
	loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40 + 70, 130, 320, 30)];
	[loadingLabel setText:@"Loading..."];
	[loadingLabel setBackgroundColor:[UIColor blackColor]];
	[loadingLabel setTextColor:[UIColor whiteColor]];
	[loadingLabel setFont:[UIFont boldSystemFontOfSize:24]];
	
	headerHeight = 20;
	
	[super viewDidLoad];
}

- (PPMTableCell *)getTableCell {
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PPMTableCell" owner:self options:nil];
	
	for(id obj in nib)
		if([obj isKindOfClass:[PPMTableCell class]])
			return (PPMTableCell *)obj;
	
	return nil;	
}

- (PPMDoubleTableCell *)getDoubleCell {
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PPMDoubleTextCell" owner:self options:nil];
		
	for(id obj in nib)
		if([obj isKindOfClass:[PPMDoubleTableCell class]])
			return (PPMDoubleTableCell *)obj;
		
	return nil;	
}

NSInteger sortOnName(LocationObject *obj1, LocationObject *obj2, void *context) {		
	return [obj1.name localizedCompare:obj2.name];
}

NSInteger sortOnDistance(id obj1, id obj2, void *context) {
    double v1 = [[obj1 valueForKey:@"distance"] doubleValue];
    double v2 = [[obj2 valueForKey:@"distance"] doubleValue];
	
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

-(BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self resignFirstResponder];
	[super viewWillDisappear:animated];
}

- (void)refreshPage {}

- (void)showLoaderIcon {
	UIApplication *app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];	
}

- (void)showLoaderIconLarge {
	[self.tableView setSeparatorColor:[UIColor blackColor]];
	[self.view addSubview:loadingLabel];
	[activityView startAnimating];	
}

- (void)hideLoaderIcon {
	UIApplication *app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:NO];
	
	[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
	[activityView stopAnimating];
	[loadingLabel removeFromSuperview];
}

- (void)hideLoaderIconLarge {
	[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
	[activityView stopAnimating];
	[loadingLabel removeFromSuperview];
}

- (void)showLocationProfile:(LocationObject*)location withMapButton:(BOOL)showMapButton {
	LocationProfileViewController *locationProfileView = [self getLocationProfile];
	
	[locationProfileView setShowMapButton:showMapButton];
	[locationProfileView setActiveLocationObject:location];
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

- (LocationProfileViewController *) getLocationProfile {
	LocationProfileViewController *locationProfileView = appDelegate.locationProfileView;
	
	if(locationProfileView == nil) {
		locationProfileView = [[LocationProfileViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	
	return locationProfileView;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {	
	if (event.type == UIEventSubtypeMotionShake) {
		UIApplication *app = [UIApplication sharedApplication];
		if (app.networkActivityIndicatorVisible == YES) {
			return;
		} 
				
		double min_dist = 1000000.0;
		double max_dist = 0.0;
		
		for(id key in appDelegate.activeRegion.locations) {
			LocationObject *locobj = (LocationObject *)[appDelegate.activeRegion.locations objectForKey:key];
			[locobj updateDistance];
			if(min_dist > locobj.distance) min_dist = locobj.distance;
			if(max_dist < locobj.distance) max_dist = locobj.distance;
		}
		
		NSMutableArray *value_array = [[NSMutableArray alloc] init];
		for(id key in appDelegate.activeRegion.locations) {
			LocationObject *locobj = (LocationObject *)[appDelegate.activeRegion.locations objectForKey:key];
			int value = ceil(pow(locobj.distance + 0.3,-1.9) * 1000);
			
			for (int i = 0; i < value; i++) {
				[value_array addObject:locobj.idNumber];
			}
		}
		
		int r = arc4random() % [value_array count];
		LocationObject *loc = [appDelegate.activeRegion.locations objectForKey:[value_array objectAtIndex:r]];
		
		NSArray *viewControllers = self.navigationController.viewControllers;
		LocationProfileViewController *vc = (LocationProfileViewController *)[viewControllers objectAtIndex:[viewControllers count] - 1];
		if([vc isKindOfClass:[LocationProfileViewController class]]) {
			vc.activeLocationObject = loc;
			[vc refreshAndReload];
		} else {
			LocationProfileViewController *locationProfileView123 = [self getLocationProfile];
			[locationProfileView123 setTitle:@"Mystery"];
            [locationProfileView123 setShowMapButton:YES];
			[locationProfileView123 setActiveLocationObject:loc];
			
			NSArray *quickArray1234 = [[NSArray alloc] initWithObjects:[self.navigationController.viewControllers objectAtIndex:0],locationProfileView123,nil];

			[self.navigationController setViewControllers:quickArray1234 animated:NO];
		}
		
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	return @"no section title";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {    
	UILabel *label = [[UILabel alloc] init];
	[label setFrame:CGRectMake(10, 0, 320, headerHeight)];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextColor:[UIColor blackColor]];
	[label setFont:[UIFont boldSystemFontOfSize:18]];
	[label setText:[self tableView:tableView titleForHeaderInSection:section]];
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, headerHeight)];
	[view setAlpha:0.9];
	[view setBackgroundColor:[UIColor whiteColor]];
	[view addSubview:label];
	
    return view;	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if([self numberOfSectionsInTableView:tableView] == 1
	   || [self tableView:tableView numberOfRowsInSection:section] == 0)
		return 0;
		
	return headerHeight ;
}

@end