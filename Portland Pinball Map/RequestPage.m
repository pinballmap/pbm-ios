//
//  RequestPage.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RequestPage.h"


@implementation RequestPage
@synthesize contactButton;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction)onContactTap:(id)sender
{
	NSLog(@"mail to"); 
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:ryan@pinballmap.com?subject=Adding%20my%20region%20to%20PinballMap.com"]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.contactButton = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[contactButton release];
    [super dealloc];
}


@end
