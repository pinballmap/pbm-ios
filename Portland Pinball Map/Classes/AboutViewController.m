#import "AboutViewController.h"

@implementation AboutViewController
@synthesize drewButton, ryanButton, scottButton, isaacButton, ppmButton, webview;

-(void)viewURL:(NSString*)url withTitle:(NSString*)string {
	if (webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	
	webview.title = string;
	webview.newURL = [NSString stringWithString:url];
	
	[self.navigationController pushViewController:webview animated:YES];
}

- (IBAction)drewButtonPress:(id)sender {
	NSString *url = [[NSString alloc] initWithString:@"http://www.workbydrew.com"];
	[self viewURL:url withTitle:@"Drew Marshall"];
	[url release];
	
}

- (IBAction)scottButtonPress:(id)sender {
	NSString *url = [[NSString alloc] initWithString:@"http://scottwainstock.com/"];
	[self viewURL:url withTitle:@"Scott Wainstock"];
	[url release];
}

- (IBAction)ryanButtonPress:(id)sender {
	NSString *url = [[NSString alloc] initWithString:@"http://blueskiesabove.us/"];
	[self viewURL:url withTitle:@"Ryan Gratzer"];
	[url release];
}

- (IBAction)isaacButtonPress:(id)sender {
	NSString *url = [[NSString alloc] initWithString:@"http://isaacruiz.net/"];
	[self viewURL:url withTitle:@"Isaac Ruiz"];
	[url release];
}

- (IBAction)ppmButtonPress:(id)sender {
	NSString *url = [[NSString alloc] initWithString:@"http://pinballmap.com/"];
	[self viewURL:url withTitle:@"PinballMap.com"];
	[url release];	
}

- (void)viewDidUnload {
	self.drewButton = nil;
	self.isaacButton = nil;
	self.ryanButton = nil;
	self.ppmButton = nil;
	self.scottButton = nil;
}

- (void)dealloc {
	[scottButton release];
	[isaacButton release];
	[ryanButton release];
	[ppmButton release];
	[drewButton release];
	[webview release];
    [super dealloc];
}

@end