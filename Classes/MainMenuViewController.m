#import "MainMenuViewController.h"
#import "Zone.h"
#import "Machine.h"
#import "RegionSelectViewController.h"

@implementation MainMenuViewController
@synthesize startingPoint, controllers, aboutView, tableTitles;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {    
	[self showInfoButton];
	
	[super viewDidLoad];
}

-(void)showInfoButton {
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(pressInfo:) forControlEvents:UIControlEventTouchUpInside];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:infoButton]];	
}

- (void)viewWillAppear:(BOOL)animated {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setTitle:[NSString stringWithFormat:@"%@ Pinball Map", appDelegate.activeRegion.formalName]];
    
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self setTitle:[NSString stringWithFormat:@"%@ Pinball Map", appDelegate.activeRegion.formalName]];

    if (appDelegate.internetActive) {
        tableTitles = @[@"Locations", @"Machines", @"Closest Locations", @"Recently Added", @"Events", @"Change Region"];
    } else {
        NSLog(@"INTERNET NOT ACTIVE");
        
        tableTitles = @[@"Locations", @"Machines", @"Events"];
    }
        
    if (appDelegate.noConnectionOrSavedData) {
        NSLog(@"MAIN MENU NO CONNECTION OR SAVED DATA");
        
        UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"No connection or cached data available"
							  message:@"You have no saved location data, and no Internet connection. Please try again after you get a connection."
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
    } else if (appDelegate.noConnectionSavedDataAvailable) {
        NSLog(@"MAIN MENU NO CONNECTION BUT THERE IS SAVED DATA");

        UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Using cached data"
							  message:@"You have no Internet connection. But, you do have some saved location data from earlier. I'm going to use this."
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
        
        [self showMenu];
	} else if (appDelegate.activeRegion.locations == nil || [appDelegate.activeRegion.locations count] == 0) {
        NSLog(@"NO ACTIVE REGION READY TO GO");
        motd = nil;
        
        [appDelegate showSplashScreen];
        //[appDelegate fetchRegionData]; //couldn't get this to work without it
        [appDelegate fetchLocationData];
        
        if (motd != nil && ![motd isKindOfClass:[NSNull class]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Of The Day" message:motd delegate:self cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
            [alert show];
        }
         
        [self showMenu];
	}
	
	[super viewDidAppear:animated];
}

- (void)showMenu {
    if (self.controllers == nil) {
        NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
        
        ZonesViewController *locView = [[ZonesViewController alloc] initWithStyle:UITableViewStylePlain];
        [locView setTitle:@"Locations"];
        [viewControllers addObject:locView];
        
        MachineViewController *machView = [[MachineViewController alloc] initWithStyle:UITableViewStylePlain];
        [machView setTitle:@"Machines"];
        [viewControllers addObject:machView];
        
        if (appDelegate.internetActive) {
            ClosestLocations *closest = [[ClosestLocations alloc] initWithStyle:UITableViewStylePlain];
            [closest setTitle:@"Closest Locations"];
            [viewControllers addObject:closest];
            
            RecentlyAddedViewController *rssView = [[RecentlyAddedViewController alloc] initWithStyle:UITableViewStylePlain];
            [rssView setTitle:@"Recently Added"];
            [viewControllers addObject:rssView];
        }
        
        if ([appDelegate.activeRegion.events count] != 0 || appDelegate.internetActive) {
            EventsViewController *eventView = [[EventsViewController alloc] initWithStyle:UITableViewStylePlain];
            [eventView setTitle:@"Events"];
            [viewControllers addObject:eventView];
        }
        
        if (appDelegate.internetActive) {            
            RegionSelectViewController *regionSelect = [[RegionSelectViewController alloc] initWithStyle:UITableViewStylePlain];
            [regionSelect setTitle:@"Change Region"];
            [viewControllers addObject:regionSelect];
        }
            
        [self setControllers:viewControllers];
    }
    
    [appDelegate hideSplashScreen];
    [self.tableView reloadData];
    [self hideLoaderIcon];

    if (appDelegate.isPad) {
        [appDelegate.splitViewController.view setHidden:NO];
        [appDelegate.locationMap setLocationsToShow:appDelegate.activeRegion.locations.allObjects];
        [appDelegate.locationMap loadPins];
    }
}

- (void)alertNoConnectionFound {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"No Internet Connection Found"
                          message:@"Please close the app and try again."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [controllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PBMTableCell *cell = (PBMTableCell*)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
    if (cell == nil) {
		cell = [self getTableCell];
	}

	[cell.nameLabel setText:tableTitles[[indexPath row]]];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.navigationController pushViewController:self.controllers[[indexPath row]] animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {	
	if(buttonIndex == 0) {
        [appDelegate fetchRegionData];
    }
}

- (void)pressInfo:(id)sender {
	if (aboutView == nil) {
		aboutView = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
		[aboutView setTitle:@"About"];
	}
	
	[self.navigationController pushViewController:aboutView animated:YES];
}

@end