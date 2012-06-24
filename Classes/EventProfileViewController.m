#import "EventProfileViewController.h"

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
     
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mmm-dd-yyyy"];
    
	[locationLabel setText:event.location.name ? [NSString stringWithFormat:@"@ %@", event.location.name] : @""];
	[timeLabel setText:[formatter stringFromDate:event.startDate]];
	[descText setText:event.longDesc];
    
	[super viewWillAppear:animated];
}

- (IBAction)onLocationTap:(id)sender {
	LocationProfileViewController *locationProfileView = [[LocationProfileViewController alloc] initWithStyle:UITableViewStylePlain];
	
	[locationProfileView setShowMapButton:YES];
	[locationProfileView setActiveLocation:event.location];
	
	[self.navigationController pushViewController:locationProfileView animated:YES];
}

- (IBAction)onWebTap:(id)sender {
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	[webview setTitle:nameLabel.text];
	[webview setTheNewURL:event.externalLink];
	
	[self.navigationController pushViewController:webview animated:YES];
}

@end