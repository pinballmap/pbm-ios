//
//  BlackTableViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Portland_Pinball_MapAppDelegate.h"
#import "BlackTableViewController.h"
#import "LocationProfileViewController.h"


@implementation BlackTableViewController
@synthesize alphabet;
@synthesize headerHeight;
@synthesize activityView;
@synthesize loadingLabel;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad
{
	self.tableView.separatorColor = [UIColor darkGrayColor];
	self.view.backgroundColor = [UIColor blackColor];
	
	// Build Loading Icon
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(70,130,30,30);
	[self.view addSubview:activityView];
	
	loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40 + 70, 130, 320, 30)];
	loadingLabel.text = @"Loading...";
	loadingLabel.backgroundColor = [UIColor blackColor];
	loadingLabel.textColor       = [UIColor whiteColor];
	loadingLabel.font            = [UIFont boldSystemFontOfSize:24];
	
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	alphabet = [[NSArray alloc] initWithObjects:@"#",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",
				@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",
				@"u",@"v",@"w",@"x",@"y",@"z",nil];
	headerHeight = 20;
	
	[super viewDidLoad];
}

-(PPMTableCell *)getTableCell
{
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PPMTableCell" owner:self options:nil];
	
	for(id obj in nib)
		if([obj isKindOfClass:[PPMTableCell class]])
			return (PPMTableCell *)obj;
	
	NSLog(@"Error: BlackTableViewCell getTableCell: NO CELL FOUND!");
	return nil;
	
}

-(PPMDoubleTableCell *)getDoubleCell
{
	
	//static NSString *DoubleIdentifier = @"DoubleTextCellID";

	//PPMDoubleTableCell *cell = (PPMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:DoubleIdentifier];
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PPMDoubleTextCell" owner:self options:nil];
		
	for(id obj in nib)
		if([obj isKindOfClass:[PPMDoubleTableCell class]])
			return (PPMDoubleTableCell *)obj;
		
	NSLog(@"Error: BlackTableViewCell getDoubleCell: NO CELL FOUND!");
	return nil;
	
}

#pragma mark Sorting Functions

NSInteger sortOnName(LocationObject *obj1, LocationObject *obj2, void *context)
{
	
	////NSLog(@"Sort on name!");
    NSString * v1 = obj1.name;
    NSString * v2 = obj2.name;
	
	//NSLog(@"sorting these strings: %@ %@",v1,v2);
	
	return [v1 localizedCompare:v2];
}

NSInteger sortOnDistance(id obj1, id obj2, void *context)
{
    double  v1 = [[obj1 valueForKey:@"distance"] doubleValue];
    double  v2 = [[obj2 valueForKey:@"distance"] doubleValue];
	
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}



/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

-(BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	
    [super viewDidAppear:animated];
	[self becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[self resignFirstResponder];
	[super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)refreshPage
{
	//override me
}


#pragma mark Loader Icons

-(void)showLoaderIcon
{
	//NSLog(@"showLoaderIcon");
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
}

-(void)showLoaderIconLarge
{
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.separatorColor = [UIColor blackColor];
	[self.view addSubview:loadingLabel];
	[activityView startAnimating];
	
}

-(void)hideLoaderIcon
{
	//NSLog(@"hideLoaderIcon");
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	self.tableView.separatorColor = [UIColor darkGrayColor];
	[activityView stopAnimating];
	[loadingLabel removeFromSuperview];
}

-(void)hideLoaderIconLarge
{
	self.tableView.separatorColor = [UIColor darkGrayColor];
	[activityView stopAnimating];
	[loadingLabel removeFromSuperview];
	
}


#pragma mark Show Location Profile
-(void) showLocationProfile:(LocationObject*)location withMapButton:(BOOL)showMapButton
{
	LocationProfileViewController *locationProfileView = [self getLocationProfile];
	
	locationProfileView.showMapButton        = showMapButton;
	locationProfileView.activeLocationObject = location;
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

-(LocationProfileViewController *) getLocationProfile
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	LocationProfileViewController *locationProfileView = appDelegate.locationProfileView;
	
	if(locationProfileView == nil)
	{
		locationProfileView = [[LocationProfileViewController alloc]  initWithStyle:UITableViewStylePlain];
	}
	
	return locationProfileView;
}

#pragma mark Detect Shakey

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSLog(@"Motion Something");
	if (event.type == UIEventSubtypeMotionShake)
	{
		UIApplication* app = [UIApplication sharedApplication];
		if(app.networkActivityIndicatorVisible == YES)
		{
			NSLog(@"App Loading, Shakey Denied");
			return;
		}
		else 
		{
			NSLog(@"Shakey Granted");
		}
		
		/*
		 for (var i:int = 0 ; i < total_locations; i++)
		 {
		 var loc:Number = Math.random() * 12;
		 locationArray.push({loc:loc,val:0});
		 min_dist = Math.min(loc,min_dist);
		 max_dist = Math.max(loc,max_dist);
		 }
		 
		 var total_value:Number = 0;
		 for (i = 0 ; i < total_locations; i++)
		 {
		 var loc3:Number = locationArray[i].loc;
		 var p:Number = ((loc3 - min_dist) / (max_dist - min_dist));
		 p = Math.abs(p - 1);
		 //var v:Number = (p *  (max_value - min_value)) + min_value;
		 var v:Number = Math.pow(loc3 + 1,-2) * max_value;
		 values.push(v);
		 total_value += v;
		 }
		 
		 textfield.autoSize = "left";
		 textfield.width = 600;
		 textfield.text = "total_value:" + total_value;
		 
		 for ( i = 0 ; i < total_locations; i++)
		 {
		 textfield.appendText("\r============");
		 
		 var loc2:Number = locationArray[i].loc;
		 var val:Number = values[i];
		 var p1:Number = Number(val / total_value * 100)
		 textfield.appendText("\r" + "  distance: " + loc2.toFixed(2) + "L");
		 textfield.appendText("\r" + "  value: "    + values[i].toFixed(4) + " (" + p1.toFixed(2) + "%)4");
		 }
		 */
		
		double min_dist = 1000000.0;
		double max_dist = 0.0;
		
		//Loop 1: Update Locations - Get Min and Max Dist
		for(id key in appDelegate.activeRegion.locations)
		{
			LocationObject *locobj = (LocationObject *)[appDelegate.activeRegion.locations objectForKey:key];
			[locobj updateDistance];
			if(min_dist > locobj.distance) min_dist = locobj.distance;
			if(max_dist < locobj.distance) max_dist = locobj.distance;
		}
		
		//Loop 2: Assign Values
		NSMutableArray *value_array = [[NSMutableArray alloc] init];
		for(id key in appDelegate.activeRegion.locations)
		{
			LocationObject *locobj = (LocationObject *)[appDelegate.activeRegion.locations objectForKey:key];
			int value = ceil(pow(locobj.distance + 0.3,-1.9) * 1000);
			
			for (int i = 0; i < value; i++)
			{
				[value_array addObject:locobj.id_number];
			}
		}
		
		int r = arc4random() % [value_array count];
		LocationObject *loc = [appDelegate.activeRegion.locations objectForKey:[value_array objectAtIndex:r]];
		
		NSArray *vcarray = self.navigationController.viewControllers;
		LocationProfileViewController *vc = (LocationProfileViewController *)[vcarray objectAtIndex:[vcarray count] - 1];
		if([vc isKindOfClass:[LocationProfileViewController class]])
		{
			vc.activeLocationObject = loc;
			[vc refreshAndReload];
		}
		else
		{
			LocationProfileViewController *locationProfileView123 = [self getLocationProfile];
			locationProfileView123.title = @"Mystery";
			locationProfileView123.showMapButton = YES;
			locationProfileView123.activeLocationObject = loc;
			
			NSArray *quickArray1234 = [[NSArray alloc] initWithObjects:[self.navigationController.viewControllers objectAtIndex:0],locationProfileView123,nil];
			[self.navigationController setViewControllers:quickArray1234 animated:NO];
			[quickArray1234 release];
			
			//[self performSelector:@selector(updateMyControllers) withObject:nil afterDelay:0.5]; 
			//[self showLocationProfile:loc withMapButton:YES];
		}
		
		[value_array release];
		
		
		
		
		
		/*		
		 NSArray *keys = [appDelegate.activeRegion.locations allKeys];
		 srandom(time(NULL));
		 int r = random() % [keys count];
		 LocationObject *loc = [appDelegate.activeRegion.locations objectForKey:[keys objectAtIndex:r]];
		 
		 NSArray *vcarray = self.navigationController.viewControllers;
		 LocationProfileViewController *vc = (LocationProfileViewController *)[vcarray objectAtIndex:[vcarray count] - 1];
		 if([vc isKindOfClass:[LocationProfileViewController class]])
		 {
		 vc.activeLocationObject = loc;
		 [vc refreshAndReload];
		 }
		 else
		 {
		 LocationProfileViewController *locationProfileView = [self getLocationProfile];
		 locationProfileView.title = @"Mystery";
		 locationProfileView.showMapButton = YES;
		 locationProfileView.activeLocationObject = loc;
		 
		 NSArray *quickArray = [[NSArray alloc] initWithObjects:self,locationProfileView,nil];
		 [self.navigationController setViewControllers:quickArray animated:NO];
		 [quickArray release];
		 
		 //[self performSelector:@selector(updateMyControllers) withObject:nil afterDelay:0.5]; 
		 //[self showLocationProfile:loc withMapButton:YES];
		 }*/
	}
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	NSString *returnString = @"no section title";
	return returnString;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
	NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
	NSString *extraString = [[NSString alloc] initWithFormat:@"%@",sectionTitle];
	UILabel *label = [[[UILabel alloc] init] autorelease];
	label.frame = CGRectMake(10, 0, 320, headerHeight);
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	//[UIColor colorWithRed:1.0 green:0.25 blue:1.0 alpha:1.0];
	//[UIColor blackColor]; //[UIColor colorWithRed:0.4588 green:0.9686 blue:0.0 alpha:1.0]; //[UIColor whiteColor];//
	label.font = [UIFont boldSystemFontOfSize:18];
	label.text = extraString;
	
	[extraString release];
	
	// Create header view and add label as a subview
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, headerHeight)];
	view.alpha = 0.9;
	view.backgroundColor = [UIColor whiteColor];
	//[UIColor colorWithRed:0.4 green:0.0 blue:0.4786 alpha:1.0];
	//[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0];
	//[UIColor whiteColor];// 0.4 0.0 0.4843 //  [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0]; 
	[view autorelease];
	[view addSubview:label];
	return view;	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
	}
    
    // Set up the cell...
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if([self numberOfSectionsInTableView:tableView] == 1
	   || [self tableView:tableView numberOfRowsInSection:section] == 0)
		return 0;
		
	return headerHeight ;
}

- (void)dealloc 
{
	[alphabet release];
	[activityView release];
	[loadingLabel release];

    [super dealloc];
}


@end

