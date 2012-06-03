#import "Portland_Pinball_MapAppDelegate.h"
#import "BlackTableViewController.h"
#import "LocationProfileViewController.h"

@implementation BlackTableViewController
@synthesize alphabet, headerHeight, activityView, loadingLabel;

- (void)viewDidLoad {
	self.tableView.separatorColor = [UIColor darkGrayColor];
	self.view.backgroundColor = [UIColor blackColor];
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(70,130,30,30);
	[self.view addSubview:activityView];
	
	loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40 + 70, 130, 320, 30)];
	loadingLabel.text = @"Loading...";
	loadingLabel.backgroundColor = [UIColor blackColor];
	loadingLabel.textColor = [UIColor whiteColor];
	loadingLabel.font = [UIFont boldSystemFontOfSize:24];
	
	alphabet = [[NSArray alloc] initWithObjects:@"#",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",
				@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",
				@"u",@"v",@"w",@"x",@"y",@"z",nil];
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
    NSString * v1 = obj1.name;
    NSString * v2 = obj2.name;
		
	return [v1 localizedCompare:v2];
}

NSInteger sortOnDistance(id obj1, id obj2, void *context) {
    double  v1 = [[obj1 valueForKey:@"distance"] doubleValue];
    double  v2 = [[obj2 valueForKey:@"distance"] doubleValue];
	
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
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;	
}

- (void)showLoaderIconLarge {
	self.tableView.separatorColor = [UIColor blackColor];
	[self.view addSubview:loadingLabel];
	[activityView startAnimating];	
}

- (void)hideLoaderIcon {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	self.tableView.separatorColor = [UIColor darkGrayColor];
	[activityView stopAnimating];
	[loadingLabel removeFromSuperview];
}

- (void)hideLoaderIconLarge {
	self.tableView.separatorColor = [UIColor darkGrayColor];
	[activityView stopAnimating];
	[loadingLabel removeFromSuperview];
}

- (void)showLocationProfile:(LocationObject*)location withMapButton:(BOOL)showMapButton {
	LocationProfileViewController *locationProfileView = [self getLocationProfile];
	
	locationProfileView.showMapButton        = showMapButton;
	locationProfileView.activeLocationObject = location;
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

- (LocationProfileViewController *) getLocationProfile {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	LocationProfileViewController *locationProfileView = appDelegate.locationProfileView;
	
	if(locationProfileView == nil) {
		locationProfileView = [[LocationProfileViewController alloc]  initWithStyle:UITableViewStylePlain];
	}
	
	return locationProfileView;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (event.type == UIEventSubtypeMotionShake) {
		UIApplication* app = [UIApplication sharedApplication];
		if(app.networkActivityIndicatorVisible == YES) {
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
				[value_array addObject:locobj.id_number];
			}
		}
		
		int r = arc4random() % [value_array count];
		LocationObject *loc = [appDelegate.activeRegion.locations objectForKey:[value_array objectAtIndex:r]];
		
		NSArray *vcarray = self.navigationController.viewControllers;
		LocationProfileViewController *vc = (LocationProfileViewController *)[vcarray objectAtIndex:[vcarray count] - 1];
		if([vc isKindOfClass:[LocationProfileViewController class]]) {
			vc.activeLocationObject = loc;
			[vc refreshAndReload];
		} else {
			LocationProfileViewController *locationProfileView123 = [self getLocationProfile];
			locationProfileView123.title = @"Mystery";
			locationProfileView123.showMapButton = YES;
			locationProfileView123.activeLocationObject = loc;
			
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
	NSString *returnString = @"no section title";
	return returnString;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
	NSString *extraString = [[NSString alloc] initWithFormat:@"%@",sectionTitle];
	UILabel *label = [[UILabel alloc] init];
	label.frame = CGRectMake(10, 0, 320, headerHeight);
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.font = [UIFont boldSystemFontOfSize:18];
	label.text = extraString;
	
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, headerHeight)];
	view.alpha = 0.9;
	view.backgroundColor = [UIColor whiteColor];
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