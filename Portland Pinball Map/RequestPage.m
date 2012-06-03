#import "RequestPage.h"

@implementation RequestPage
@synthesize contactButton;

- (IBAction)onContactTap:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:ryan@pinballmap.com?subject=Adding%20my%20region%20to%20PinballMap.com"]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.contactButton = nil;
}


@end