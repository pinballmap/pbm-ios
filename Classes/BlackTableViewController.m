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

- (PBMTableCell *)getTableCell {
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PBMTableCell" owner:self options:nil];
	
	for(id obj in nib)
		if([obj isKindOfClass:[PBMTableCell class]])
			return (PBMTableCell *)obj;
	
	return nil;	
}

- (PBMDoubleTableCell *)getDoubleCell {
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PBMDoubleTextCell" owner:self options:nil];
		
	for(id obj in nib)
		if([obj isKindOfClass:[PBMDoubleTableCell class]])
			return (PBMDoubleTableCell *)obj;
		
	return nil;	
}

NSInteger sortOnName(Location *obj1, Location *obj2, void *context) {		
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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
        initWithTitle: @"Back" 
        style: UIBarButtonItemStyleBordered
        target: nil action: nil
    ];
    [self.navigationItem setBackBarButtonItem: backButton];
    
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

- (void)showLocationProfile:(Location*)location withMapButton:(BOOL)showMapButton {
    if (appDelegate.isPad) {
        showMapButton = NO;
    }
    
	LocationProfileViewController *locationProfileView = [[LocationProfileViewController alloc] initWithStyle:UITableViewStylePlain];
	
	[locationProfileView setShowMapButton:showMapButton];
	[locationProfileView setActiveLocation:location];
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {	
	if (event.type == UIEventSubtypeMotionShake) {
		UIApplication *app = [UIApplication sharedApplication];
		if (app.networkActivityIndicatorVisible == YES) {
			return;
		} 
				
		double min_dist = 1000000.0;
		double max_dist = 0.0;
		
        NSMutableArray *randSeed = [[NSMutableArray alloc] init];
		for(Location *location in appDelegate.activeRegion.locations) {
			[location updateDistance];
			if(min_dist > location.distance) min_dist = location.distance;
			if(max_dist < location.distance) max_dist = location.distance;
            
            int maxDistance = ceil(pow(location.distance + 0.3, -1.9) * 1000);
			
			for (int i = 0; i < maxDistance; i++) {
				[randSeed addObject:location];
			}
		}
		
		int random = arc4random() % [randSeed count];
		Location *location = [randSeed objectAtIndex:random];
		
		NSArray *viewControllers = self.navigationController.viewControllers;
		LocationProfileViewController *vc = (LocationProfileViewController *)[viewControllers objectAtIndex:[viewControllers count] - 1];
		if([vc isKindOfClass:[LocationProfileViewController class]]) {
			vc.activeLocation = location;
			[vc refreshAndReload];
		} else {
			LocationProfileViewController *locationProfileView = [[LocationProfileViewController alloc] initWithStyle:UITableViewStylePlain];
			[locationProfileView setTitle:@"Mystery"];
            [locationProfileView setShowMapButton:YES];
			[locationProfileView setActiveLocation:location];
			
			[self.navigationController setViewControllers:@[[self.navigationController.viewControllers objectAtIndex:0], locationProfileView] animated:NO];
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
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if([self numberOfSectionsInTableView:tableView] == 1 || [self tableView:tableView numberOfRowsInSection:section] == 0)
		return 0;
		
	return headerHeight;
}

@end