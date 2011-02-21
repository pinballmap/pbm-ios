//
//  EventProfileViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"


@implementation EventProfileViewController
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize timeLabel;
@synthesize webButton;
@synthesize locationButton;
@synthesize descText;
@synthesize eventObject;
@synthesize webview;

-(void)viewDidLoad
{
	self.title = @"Events";
	descText.editable = NO;
	//webButton.hidden = YES; 
	
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	if([eventObject.name isEqualToString:@""])
		nameLabel.text = [NSString stringWithFormat:@"%@ Tournament",eventObject.location.name];
	else 
		nameLabel.text = [NSString stringWithString:eventObject.name];

	locationLabel.text = [NSString stringWithFormat:@"@ %@",eventObject.location.name];
	timeLabel.text = eventObject.displayDate;
	descText.text = eventObject.longDesc;
	[super viewWillAppear:animated];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


-(IBAction)onLocationTap:(id)sender
{
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	LocationProfileViewController *locationProfileView = appDelegate.locationProfileView;
	
	if(locationProfileView == nil)
	{
		locationProfileView = [[LocationProfileViewController alloc]  initWithStyle:UITableViewStylePlain];
		
		//UILabel *label = [[[UILabel alloc] init] autorelease];
		//[locationProfileView.view addSubview:label];
	}
	
	locationProfileView.showMapButton = YES;
	locationProfileView.activeLocationObject = eventObject.location;
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}
-(IBAction)onWebTap:(id)sender
{
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	webview.title = nameLabel.text;
	webview.newURL = [NSString stringWithString:eventObject.link];
	
	[self.navigationController pushViewController:webview animated:YES];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.nameLabel = nil;
	self.locationButton = nil;
	self.timeLabel = nil;
	self.webButton = nil;
	self.locationButton = nil;
	self.descText = nil;
}


- (void)dealloc {
	
	[webview release];
	[eventObject release];
	[nameLabel release];
	[locationButton release];
	[timeLabel release];
	[webButton release];
	[descText release];
	[locationButton release];
    [super dealloc];
}


@end
