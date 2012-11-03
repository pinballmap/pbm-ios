#import "Utils.h"
#import "AddMachineViewController.h"
#import "MachineProfileViewController.h"
#import "LocationProfileViewController.h"

@implementation LocationProfileViewController
@synthesize scrollView, mapLabel, mapButton, showMapButton, activeLocation, addMachineButton;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	[scrollView setContentSize:CGSizeMake(320,460)];
	[scrollView setMaximumZoomScale:1];
	[scrollView setMinimumZoomScale:1];
	[scrollView setClipsToBounds:YES];	
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return nil;
}

- (IBAction)addMachineButtonPressed:(id)sender {
    AddMachineViewController *addMachineView = [[AddMachineViewController alloc] initWithNibName:@"AddMachineView" bundle:nil];
    [addMachineView setTitle:@"Add a New Machine"];
    
	[addMachineView setLocation:self.activeLocation];
    
	[self.navigationController pushViewController:addMachineView animated:YES];
}

- (IBAction)mapButtonPressed:(id)sender {}

- (void)viewWillAppear:(BOOL)animated {
	[self refreshPage];
    
	[super viewWillAppear:(BOOL)animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[self loadLocationData];
	
	[super viewDidAppear:animated];
}

- (void)refreshAndReload {
	[self refreshPage];
	[self loadLocationData];
}

- (void)loadLocationData {
	if (!activeLocation.isLoaded) {
		UIApplication *app = [UIApplication sharedApplication];
		[app setNetworkActivityIndicatorVisible:YES];
    
		        
        dispatch_async(kBgQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@locations/%@.json", appDelegate.rootURL, activeLocation.idNumber]]];
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        });
	}
}

- (void)refreshPage {
	[scrollView setContentOffset:CGPointMake(0, 0)];
	[self setTitle:activeLocation.name];
	
	(activeLocation.isLoaded) ? [self hideLoaderIconLarge] : [self showLoaderIconLarge];
	
	[self.tableView reloadData];
    
    if (appDelegate.isPad) {
        [appDelegate.locationMap setLocationsToShow:@[activeLocation]];
        [appDelegate.locationMap loadPins];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (activeLocation.isLoaded == NO) ? 0 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(activeLocation.isLoaded == NO) {
        return 0;
    }
    
	switch (section) {
		case 0:
			return showMapButton ? 3 : 2;
			break;
		case 1:
		default:
			return [activeLocation.locationMachineXrefs count];
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	if (section == 0 && row == 0) {
		LocationProfileCell *cellA = (LocationProfileCell*)[tableView dequeueReusableCellWithIdentifier:@"LocationCellID"];
		if (cellA == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationProfileCellView" owner:self options:nil];
			
			for(id obj in nib) {
				if([obj isKindOfClass:[LocationProfileCell class]])
					cellA = (LocationProfileCell *)obj;
			}
		}
		
		if (activeLocation.isLoaded) {
            [cellA.addressLabel1 setText:activeLocation.street1];
            [cellA.addressLabel2 setText:[NSString stringWithFormat:@"%@, %@ %@",activeLocation.city, activeLocation.state, activeLocation.zip]];
            [cellA.phoneLabel setText:activeLocation.phone];
            [cellA.distanceLabel setText:[NSString stringWithFormat:@"≈ %@", activeLocation.formattedDistance]];
										 
		} else {
			[cellA.addressLabel1 setText:@""];
			[cellA.addressLabel2 setText:@""];
			[cellA.phoneLabel setText:@""];
			[cellA.distanceLabel setText:@""];
		}

		[cellA.label setText:activeLocation.name];
		
		return cellA;
	} else {
		PBMTableCell *cell = (PBMTableCell*)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
		if (cell == nil) {
			cell = [self getTableCell];
		}
        
        [cell.nameLabel setText:(section == 0) ?
            ((showMapButton && row == 1) ? @"Map" : @"Add Machine") :
            [[[activeLocation.sortedLocationMachineXrefs objectAtIndex:row] machine] name]
        ];
		
		return cell;
	}
		
	return nil;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 0 && [indexPath row] == 0)
		return 116.0f;
	
    return tv.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
    return section == 0 ? @"Location" : @"Machines";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
	if(indexPath.section == 0) {
		if(showMapButton && row == 1) {
            [appDelegate.locationMap setShowProfileButtons:NO];
            [appDelegate.locationMap setLocationsToShow:@[activeLocation]];
            [appDelegate.locationMap setTitle:activeLocation.name];
        
            [self.navigationController pushViewController:appDelegate.locationMap animated:YES];
		} else {
            AddMachineViewController *addMachineView = [[AddMachineViewController alloc] initWithNibName:@"AddMachineView" bundle:nil];            
			[addMachineView setLocation:self.activeLocation];
            
			[self.navigationController pushViewController:addMachineView animated:YES];
		}
	} else if(indexPath.section == 1) {
        MachineProfileViewController *machineProfileView = [[MachineProfileViewController alloc] initWithNibName:@"MachineProfileView" bundle:nil];		
		[machineProfileView setTitle:activeLocation.name];
        [machineProfileView setLocationMachineXref:[activeLocation.sortedLocationMachineXrefs objectAtIndex:indexPath.row]];
        
		[self.navigationController pushViewController:machineProfileView animated:YES];
	}	
}

- (void)fetchedData:(NSData *)data {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *locationContainer = json[@"location"];
    NSDictionary *locationData = locationContainer[@"location"];
    NSArray *machines = json[@"machines"];
    
    Location *location = (Location *)[appDelegate fetchObject:@"Location" where:@"idNumber" equals:locationData[@"id"]];    
    [location setStreet1:locationData[@"street"]];
    [location setCity:locationData[@"city"]];
    [location setState:locationData[@"state"]];
    [location setZip:locationData[@"zip"]];
    [location setPhone:locationData[@"phone"]];
    
    for (NSDictionary *machineContainer in machines) {
        NSDictionary *machineData = machineContainer[@"machine"];
        LocationMachineXref *xref = [NSEntityDescription insertNewObjectForEntityForName:@"LocationMachineXref" inManagedObjectContext:appDelegate.managedObjectContext];
        [xref setMachine:(Machine *)[appDelegate fetchObject:@"Machine" where:@"idNumber" equals:machineData[@"id"]]];
        
        if (machineData[@"condition"] != ((NSString *)[NSNull null])) {
            [xref setCondition:[Utils urlDecode:machineData[@"condition"]]];
            [xref setConditionDate:[formatter dateFromString:machineData[@"condition_date"]]];
        }
        
        [xref setLocation:location];
        [location addLocationMachineXrefsObject:xref];
    }
    
    [appDelegate saveContext];
    
    activeLocation = (Location *)[appDelegate fetchObject:@"Location" where:@"idNumber" equals:locationData[@"id"]];
    
    [self refreshPage];
}

@end