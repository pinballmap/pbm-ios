//
//  BlackSectionViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BlackSectionViewController.h"


@implementation BlackSectionViewController
@synthesize alphabet;

- (void)viewDidLoad {
	
	alphabet = [[NSArray alloc] initWithObjects:@"#",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",
												@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",
												@"u",@"v",@"w",@"x",@"y",@"z",nil];
	headerHeight = 20;
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	alphabet = nil;
	[alphabet release];
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return headerHeight ;
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
	view.alpha = 0.8;
	view.backgroundColor = [UIColor whiteColor];
	//[UIColor colorWithRed:0.4 green:0.0 blue:0.4786 alpha:1.0];
	//[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0];
	//[UIColor whiteColor];// 0.4 0.0 0.4843 //  [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0]; 
	[view autorelease];
	[view addSubview:label];
	return view;	
}


- (void)dealloc {
	[alphabet release];
    [super dealloc];
}


@end

