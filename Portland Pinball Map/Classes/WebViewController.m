//
//  WebViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"


@implementation WebViewController
@synthesize webview;
@synthesize newURL;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	
	webview.delegate = self;
	webview.scalesPageToFit = YES;
	
	//preload IPDB
	
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:@"http://ipdb.org"];
	
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	//Load the request in the UIWebView.
	[webview loadRequest:requestObj];
	
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	NSString *urlAddress = newURL;
	
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	
	NSLog(@"webview: %@",newURL);
	
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	//Load the request in the UIWebView.
	[webview loadRequest:requestObj];
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[webview stopLoading];
	
	//Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	[super viewWillDisappear:animated];
}


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
	self.webview = nil;
}

-(IBAction)onBackTap:(id)sender
{
	if(webview.canGoBack) [webview goBack];
}
-(IBAction)onForwardTap:(id)sender
{
	if(webview.canGoForward) [webview goForward];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	//Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
}

- (void)dealloc
{
	[newURL release];
	[webview release];
    [super dealloc];
}


@end
