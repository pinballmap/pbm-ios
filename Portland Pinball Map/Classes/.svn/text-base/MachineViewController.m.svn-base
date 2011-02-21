//
//  MachineViewController.m
//  Portland Pinball Map
//
//  Created By Isaac Ruiz on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MachineViewController.h"
#import "BlackTableViewController.h"


@implementation MachineViewController
@synthesize sortedMachines;
@synthesize keys;
@synthesize machineFilter;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
		
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	NSLog(@" >>>> MachineViewController viewDidUnload");
	[super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.title = @"back";
	[super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
	self.title = @"Machines";
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(sortedMachines != nil) [sortedMachines release];
	
	sortedMachines = [[NSMutableDictionary alloc] init];
	
	for(id key in appDelegate.activeRegion.machines)
	{
		NSDictionary *machine = [appDelegate.activeRegion.machines valueForKey:key];
		NSString *machineName = [machine valueForKey:@"name"];
		if([machineName length] == 0) 
		{
			NSLog(@"Machine #%@ has no name!",key);
			continue;
		}
		
		NSString *firstLetter = [[NSString alloc] initWithString:[[machineName substringToIndex:1] lowercaseString]];
		
		//Check for "No More Pinball"
		NSString *noMorePin = [[NSString alloc] initWithString:@"no more pinball"];
		NSRange range = [machineName rangeOfString:noMorePin];
		[noMorePin release];
		
		if (range.length == 0)
		{
			//Check For Number
			NSString *searchString = [[NSString alloc] initWithString:@"abcdefghijklmnopqrstuvwxyz"];
			NSRange letterRange = [searchString rangeOfString:firstLetter];
			if (letterRange.length == 0) 
			{
				//firstLetter = @"#";
				[firstLetter release];
				firstLetter = [[NSString alloc] initWithString:@"#"];
			}		
			
			NSMutableArray *letterArray = [sortedMachines objectForKey:firstLetter];
			if(letterArray == nil)
			{
				NSMutableArray *newLetterArray = [[NSMutableArray alloc] init];
				[sortedMachines setObject:newLetterArray forKey:firstLetter];
				letterArray = newLetterArray;
				[newLetterArray release];
			}
			
			[letterArray addObject:machine];
			
			[firstLetter release];
			[searchString release];
		}
	}
	
	for(id key in sortedMachines)
	{
		NSMutableArray *orig_array = [sortedMachines objectForKey:key];
		NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)] autorelease];
		[orig_array sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	}
	
	NSArray *array = [[sortedMachines allKeys] sortedArrayUsingSelector:@selector(compare:)];
	self.keys = array;
	
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}



- (void)dealloc {
	[machineFilter release];
	[sortedMachines release];
	[keys release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	NSDictionary *nameSection = [sortedMachines objectForKey:key];
    return [nameSection count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	NSString *key = [keys objectAtIndex:section];
	return key;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return keys;
	//return alphabet;
}



// Customize the appearance of table view cells.
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
	if(machineFilter == nil)
	{
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

