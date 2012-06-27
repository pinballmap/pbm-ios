#import "Utils.h"
#import "LocationProfileViewController.h"

@implementation LocationProfileViewController
@synthesize scrollView, mapLabel, mapButton, showMapButton, activeLocation, isBuildingMachine, tempMachineID, tempMachineCondition, tempMachineConditionDate, tempMachineDateAdded, mapView, addMachineButton, addMachineView, machineProfileView;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	self.isBuildingMachine = NO;
	[scrollView setContentSize:CGSizeMake(320,460)];
	[scrollView setMaximumZoomScale:1];
	[scrollView setMinimumZoomScale:1];
	[scrollView setClipsToBounds:YES];	
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return nil;
}

- (IBAction)addMachineButtonPressed:(id)sender {
	if(addMachineView == nil) {
		addMachineView = [[AddMachineViewController alloc] initWithNibName:@"AddMachineView" bundle:nil];
		[addMachineView setTitle:@"Add a New Machine"];
	}
    
	[addMachineView setLocation:self.activeLocation];
    
	[self.navigationController pushViewController:addMachineView animated:YES];
}

- (IBAction)mapButtonPressed:(id)sender {}

- (void)viewWillAppear:(BOOL)animated {
	[self refreshPage];
	[super viewWillAppear:(BOOL)animated];
}

- (void)viewDidAppear:(BOOL)animated {
	parsingAttempts = 0;
	[self loadLocationData];
	
	[super viewDidAppear:animated];
}

- (void)refreshAndReload {
	[self refreshPage];
	parsingAttempts = 0;
	[self loadLocationData];
}

- (void)loadLocationData {
	if (!activeLocation.isLoaded) {
		UIApplication *app = [UIApplication sharedApplication];
		[app setNetworkActivityIndicatorVisible:YES];
    
		NSString *url = [[NSString alloc] initWithFormat:@"%@get_location=%@", appDelegate.rootURL, activeLocation.idNumber];
		
		[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:url];
	}
}

- (void)refreshPage {
	[scrollView setContentOffset:CGPointMake(0, 0)];
	[self setTitle:activeLocation.name];
	
	(activeLocation.isLoaded) ? [self hideLoaderIconLarge] : [self showLoaderIconLarge];
	
	[self.tableView reloadData];
    
    if (appDelegate.isPad) {
        [appDelegate.locationMap setLocationsToShow:[NSArray arrayWithObject:activeLocation]];
        [appDelegate.locationMap loadPins];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (activeLocation.isLoaded == NO) ? 0 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(activeLocation.isLoaded == NO)
        return 0;
    
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
	
	if(section == 0 && row == 0) {
		LocationProfileCell *cellA = (LocationProfileCell*)[tableView dequeueReusableCellWithIdentifier:@"LocationCellID"];
		if (cellA == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationProfileCellView" owner:self options:nil];
			
			for(id obj in nib) {
				if([obj isKindOfClass:[LocationProfileCell class]])
					cellA = (LocationProfileCell *)obj;
			}
		}
		
		if(activeLocation.isLoaded) {
			 NSString *addressStringA = [NSString stringWithFormat:@"%@ %@", activeLocation.street1, activeLocation.street2];
			 NSString *addressStringB = [NSString stringWithFormat:@"%@, %@ %@",activeLocation.city, activeLocation.state, activeLocation.zip];
            [cellA.addressLabel1 setText:addressStringA];
            [cellA.addressLabel2 setText:addressStringB];
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
		if (cell == nil)
			cell = [self getTableCell];
		
        [cell.nameLabel setText:(section == 0) ?
            ((showMapButton && row == 1) ? @"Map" : @"Add Machine") :
            [[[activeLocation.locationMachineXrefs.allObjects objectAtIndex:row] machine] name]
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
            if(mapView == nil) {
                mapView = [[LocationMap alloc] init];
                [mapView setShowProfileButtons:NO];
            }
        
            [mapView setLocationsToShow:[NSArray arrayWithObject:activeLocation]];
            [mapView setTitle:activeLocation.name];
        
            [self.navigationController pushViewController:mapView animated:YES];
		} else {
			if(addMachineView == nil) {
				addMachineView = [[AddMachineViewController alloc] initWithNibName:@"AddMachineView" bundle:nil];
			}
            
			[addMachineView setLocation:self.activeLocation];
            
			[self.navigationController pushViewController:addMachineView animated:YES];
		}
	} else if(indexPath.section == 1) {
		if(machineProfileView == nil) {
			machineProfileView = [[MachineProfileViewController alloc] initWithNibName:@"MachineProfileView" bundle:nil];
		}
		
		[machineProfileView setTitle:activeLocation.name];
        [machineProfileView setLocationMachineXref:[activeLocation.locationMachineXrefs.allObjects objectAtIndex:indexPath.row]];
        
		[self.navigationController pushViewController:machineProfileView animated:YES];
	}	
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"machine"]) {
		isBuildingMachine = YES;
		tempMachineID = [[NSMutableString alloc] init];
		tempMachineCondition = [[NSMutableString alloc] init];
		tempMachineDateAdded = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"condition"]) {
		tempMachineConditionDate = [[[NSString alloc] initWithString:[attributeDict objectForKey:@"date"]] mutableCopy];
	} else if ([elementName isEqualToString:@"street1"]) {
        currentStreet1 = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"street2"]) {
        currentStreet2	= [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"state"]) {
        currentState = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"city"]) {
        currentCity = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"zip"]) {
        currentZip = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"phone"]) {
        currentPhone = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(isBuildingMachine == YES) {
		if ([currentElement isEqualToString:@"id"])
            [tempMachineID appendString:string];
		if ([currentElement isEqualToString:@"condition"])
            [tempMachineCondition appendString:string];
		if ([currentElement isEqualToString:@"dateAdded"])
            [tempMachineDateAdded appendString:string];
	} else {
		if ([currentElement isEqualToString:@"street1"])
            [currentStreet1 appendString:string];
		if ([currentElement isEqualToString:@"street2"])
            [currentStreet2 appendString:string];
		if ([currentElement isEqualToString:@"city"])
            [currentCity appendString:string];
		if ([currentElement isEqualToString:@"state"])
            [currentState appendString:string];
		if ([currentElement isEqualToString:@"zip"])
            [currentZip appendString:string];
		if ([currentElement isEqualToString:@"phone"])
            [currentPhone appendString:string];
	}

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	currentElement = @"";
	
	if ([elementName isEqualToString:@"machine"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        LocationMachineXref *xref = [NSEntityDescription insertNewObjectForEntityForName:@"LocationMachineXref" inManagedObjectContext:appDelegate.managedObjectContext];
        [xref setMachine:(Machine *)[appDelegate fetchObject:@"Machine" where:@"idNumber" equals:tempMachineID]];
        [xref setCondition:[Utils urlDecode:tempMachineCondition]];
		[xref setDateAdded:[formatter dateFromString:tempMachineDateAdded]];
		[xref setConditionDate:[formatter dateFromString:tempMachineConditionDate]];
        [xref setLocation:activeLocation];
        [activeLocation addLocationMachineXrefsObject:xref];		
		
		isBuildingMachine = NO;
	} else if ([elementName isEqualToString:@"street1"]) {
		[activeLocation setStreet1:currentStreet1];
	} else if ([elementName isEqualToString:@"street2"]) {
		[activeLocation setStreet2:currentStreet2];
	} else if ([elementName isEqualToString:@"state"]) {
		[activeLocation setState:currentState];
	} else if ([elementName isEqualToString:@"city"]) {
		[activeLocation setCity:currentCity];
	} else if ([elementName isEqualToString:@"zip"]) {
		[activeLocation setZip:currentZip];
	} else if ([elementName isEqualToString:@"phone"]) {
		[activeLocation setPhone:currentPhone];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	[self refreshPage];
	
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if(parsingAttempts < MAX_PARSING_ATTEMPTS) {
		parsingAttempts++;
		[self loadLocationData];
	} else {
		UIApplication *app = [UIApplication sharedApplication];
		[app setNetworkActivityIndicatorVisible:NO];

		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Whoops." 
														message:@"There was a problem loading this location. The developers have been notified. Please try again later."
														delegate:self 
														cancelButtonTitle:@"OK" 
														otherButtonTitles:nil];
		[errorAlert show];
	}
}

@end