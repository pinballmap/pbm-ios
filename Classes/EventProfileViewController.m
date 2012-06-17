#import "EventProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation EventProfileViewController
@synthesize nameLabel, locationLabel, timeLabel, webButton, locationButton, descText, event, webview;

- (void)viewDidLoad {
	[descText setEditable:NO];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"Events"];

    [nameLabel setText:[NSString stringWithFormat:@"%@", [event.name isEqualToString:@""] ?
        [NSString stringWithFormat:@"%@ Tournament", event.location.name] :
        event.name
    ]];
     
	[locationLabel setText:event.location.name ? [NSString stringWithFormat:@"@ %@",event.location.name] : @""];
	[timeLabel setText:event.displayDate];
	[descText setText:event.longDesc];
    
	[super viewWillAppear:animated];
}

- (IBAction)onLocationTap:(id)sender {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	LocationProfileViewController *locationProfileView = appDelegate.locationProfileView;
	
	if (locationProfileView == nil) {
		locationProfileView = [[LocationProfileViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	
	[locationProfileView setShowMapButton:YES];
	[locationProfileView setActiveLocationObject:event.location];
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

- (IBAction)onWebTap:(id)sender {
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	[webview setTitle:nameLabel.text];
	[webview setTheNewURL:event.link];
	
	[self.navigationController pushViewController:webview animated:YES];
}

@end