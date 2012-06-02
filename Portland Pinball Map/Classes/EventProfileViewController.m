#import "EventProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation EventProfileViewController
@synthesize nameLabel, locationLabel, timeLabel, webButton, locationButton, descText, eventObject, webview;

- (void)viewDidLoad {
	self.title = @"Events";
	descText.editable = NO;
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	if ([eventObject.name isEqualToString:@""]) {
		nameLabel.text = [NSString stringWithFormat:@"%@ Tournament",eventObject.location.name];
	} else { 
		nameLabel.text = [NSString stringWithString:eventObject.name];
    }
        
	locationLabel.text = [NSString stringWithFormat:@"@ %@",eventObject.location.name];
	timeLabel.text = eventObject.displayDate;
	descText.text = eventObject.longDesc;
	[super viewWillAppear:animated];
}

- (IBAction)onLocationTap:(id)sender {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	LocationProfileViewController *locationProfileView = appDelegate.locationProfileView;
	
	if (locationProfileView == nil) {
		locationProfileView = [[LocationProfileViewController alloc]  initWithStyle:UITableViewStylePlain];
	}
	
	locationProfileView.showMapButton = YES;
	locationProfileView.activeLocationObject = eventObject.location;
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

- (IBAction)onWebTap:(id)sender {
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	webview.title = nameLabel.text;
	webview.newURL = [NSString stringWithString:eventObject.link];
	
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