#import "AboutViewController.h"

@implementation AboutViewController
@synthesize drewButton, ryanButton, scottButton, isaacButton, ppmButton, webview;

- (void)viewURL:(NSString *)url withTitle:(NSString *)title {
    webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	
	[webview setTitle:title];
	[webview setNewURL:url];
    
	[self.navigationController pushViewController:webview animated:YES];
}

- (IBAction)drewButtonPress:(id)sender {
	[self viewURL:@"http://www.workbydrew.com" withTitle:@"Drew Marshall"];
}

- (IBAction)scottButtonPress:(id)sender {
	[self viewURL:@"http://scottwainstock.com/" withTitle:@"Scott Wainstock"];
}

- (IBAction)ryanButtonPress:(id)sender {
	[self viewURL:@"http://blueskiesabove.us/" withTitle:@"Ryan Gratzer"];
}

- (IBAction)isaacButtonPress:(id)sender {
	[self viewURL:@"http://isaacruiz.net/" withTitle:@"Isaac Ruiz"];
}

- (IBAction)ppmButtonPress:(id)sender {
	[self viewURL:@"http://pinballmap.com/" withTitle:@"PinballMap.com"];
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