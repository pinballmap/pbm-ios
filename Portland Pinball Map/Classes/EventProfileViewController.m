#import "EventProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation EventProfileViewController
@synthesize nameLabel, locationLabel, timeLabel, webButton, locationButton, descText, eventObject, webview;

- (void)viewDidLoad {
	[self setTitle:@"Events"];
	[descText setEditable:NO];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [nameLabel setText:[NSString stringWithFormat:@"%@", [eventObject.name isEqualToString:@""] ?
        [NSString stringWithFormat:@"%@ Tournament", eventObject.location.name] :
        eventObject.name
    ]];
     
	[locationLabel setText:[NSString stringWithFormat:@"@ %@",eventObject.location.name]];
	[timeLabel setText:eventObject.displayDate];
	[descText setText:eventObject.longDesc];
    
	[super viewWillAppear:animated];
}

- (IBAction)onLocationTap:(id)sender {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	LocationProfileViewController *locationProfileView = appDelegate.locationProfileView;
	
	if (locationProfileView == nil) {
		locationProfileView = [[LocationProfileViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	
	[locationProfileView setShowMapButton:YES];
	[locationProfileView setActiveLocationObject:eventObject.location];
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

- (IBAction)onWebTap:(id)sender {
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	[webview setTitle:nameLabel.text];
	[webview setTheNewURL:eventObject.link];
	
	[self.navigationController pushViewController:webview animated:YES];
}

- (void)viewDidUnload {
	self.nameLabel = nil;
	self.locationButton = nil;
	self.timeLabel = nil;
	self.webButton = nil;
	self.locationButton = nil;
	self.descText = nil;
}

@end