//
//  AboutViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController
@synthesize drewButton;
@synthesize ryanButton;
@synthesize scottButton;
@synthesize isaacButton;
@synthesize ppmButton;
@synthesize webview;

-(void)viewURL:(NSString*)url withTitle:(NSString*)string
{
	if (webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	
	webview.title = string;
	webview.newURL = [NSString stringWithString:url];
	
	[self.navigationController pushViewController:webview animated:YES];
	
}

-(IBAction)drewButtonPress:(id)sender
{
	NSString *url = [[NSString alloc] initWithString:@"http://www.workbydrew.com"];
	[self viewURL:url withTitle:@"Drew Marshall"];
	[url release];
	
}

-(IBAction)scottButtonPress:(id)sender
{
	NSString *url = [[NSString alloc] initWithString:@"http://scottwainstock.com/"];
	[self viewURL:url withTitle:@"Scott Wainstock"];
	[url release];
	
}

-(IBAction)ryanButtonPress:(id)sender
{
	NSString *url = [[NSString alloc] initWithString:@"http://blueskiesabove.us/"];
	[self viewURL:url withTitle:@"Ryan Gratzer"];
	[url release];
	
}

-(IBAction)isaacButtonPress:(id)sender
{
	NSString *url = [[NSString alloc] initWithString:@"http://isaacruiz.net/"];
	[self viewURL:url withTitle:@"Isaac Ruiz"];
	[url release];
	
}

-(IBAction)ppmButtonPress:(id)sender
{
	NSString *url = [[NSString alloc] initWithString:@"http://pinballmap.com/"];
	[self viewURL:url withTitle:@"PinballMap.com"];
	[url release];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	self.drewButton = nil;
	self.isaacButton = nil;
	self.ryanButton = nil;
	self.ppmButton = nil;
	self.scottButton = nil;
}


- (void)dealloc
{
	[scottButton release];
	[isaacButton release];
	[ryanButton release];
	[ppmButton release];
	[drewButton release];
	[webview release];
    [super dealloc];
}


@end
