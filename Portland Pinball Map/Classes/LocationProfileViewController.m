#import "Utils.h"
#import "LocationProfileViewController.h"

@implementation LocationProfileViewController
@synthesize message, scrollView, mapLabel, mapButton, showMapButton, locationID, activeLocationObject, isBuildingMachine, labelHolder, tempMachineObject, tempMachineDict, tempMachineName, tempMachineID, tempMachineCondition, tempMachineConditionDate, tempMachineDateAdded, lineView, mapView, addMachineButton, addMachineView, displayArray, machineProfileView;

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
	[addMachineView setLocationName:activeLocationObject.name];
	[addMachineView setLocationId:activeLocationObject.idNumber];
	[addMachineView setLocation:self.activeLocationObject];
    
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
	if (isParsing == NO && activeLocationObject.isLoaded == NO) {
		UIApplication* app = [UIApplication sharedApplication];
		[app setNetworkActivityIndicatorVisible:YES];
    
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString *url = [[NSString alloc] initWithFormat:@"%@get_location=%@", appDelegate.rootURL, activeLocationObject.idNumber];
		
		[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:url];
	}
}

- (void)refreshPage {
	[scrollView setContentOffset:CGPointMake(0, 0)];
	[self setTitle:activeLocationObject.name];
	
	(activeLocationObject.isLoaded) ? [self hideLoaderIconLarge] : [self showLoaderIconLarge];
	
	if(displayArray != nil) {
		displayArray = nil;
	}
	
	displayArray = [[NSMutableArray alloc] initWithCapacity:activeLocationObject.totalMachines];
	
	for(id key in activeLocationObject.machines) {
		Machine *machineObject = (Machine *)[activeLocationObject.machines objectForKey:key];
		[displayArray addObject:machineObject];
	}
	
	NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)];
	[displayArray sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (activeLocationObject.isLoaded == NO) ? 0 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(activeLocationObject.isLoaded == NO)
        return 0;
    
	switch (section) {
		case 0:
			return showMapButton ? 3 : 2;
			break;
		case 1:
		default:
			return [displayArray count];
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
		
		if(activeLocationObject.isLoaded) {
			 NSString *addressStringA = [NSString stringWithFormat:@"%@ %@",activeLocationObject.street1,activeLocationObject.street2];
			 NSString *addressStringB = [NSString stringWithFormat:@"%@, %@ %@",activeLocationObject.city,activeLocationObject.state,activeLocationObject.zip];
            [cellA.addressLabel1 setText:addressStringA];
            [cellA.addressLabel2 setText:addressStringB];
            [cellA.phoneLabel setText:activeLocationObject.phone];
            [cellA.distanceLabel setText:[NSString stringWithFormat:@"≈ %@", activeLocationObject.distanceString]];
										 
		} else {
			[cellA.addressLabel1 setText:@""];
			[cellA.addressLabel2 setText:@""];
			[cellA.phoneLabel setText:@""];
			[cellA.distanceLabel setText:@""];
		}

		[cellA.label setText:activeLocationObject.name];
		
		return cellA;
	} else {
		PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:@"SingleTextID"];
		if (cell == nil)
			cell = [self getTableCell];
		
        [cell.nameLabel setText:(section == 0) ?
            ((showMapButton && row == 1) ? @"Map" : @"Add Machine") :
            [[displayArray objectAtIndex:row] name]
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
			
			[mapView setLocationsToShow:[NSArray arrayWithObject:activeLocationObject]];
			[mapView setTitle:activeLocationObject.name];
			
			[self.navigationController pushViewController:mapView animated:YES];
		} else {
			if(addMachineView == nil) {
				addMachineView = [[AddMachineViewController alloc] initWithNibName:@"AddMachineView" bundle:nil];
			}
            
			[addMachineView setLocationName:activeLocationObject.name];
			[addMachineView setLocationId:activeLocationObject.idNumber];
			[addMachineView setLocation:self.activeLocationObject];
            
			[self.navigationController pushViewController:addMachineView animated:YES];
		}
	} else if(indexPath.section == 1) {
		if(machineProfileView == nil) {
			machineProfileView = [[MachineProfileViewController alloc] initWithNibName:@"MachineProfileView" bundle:nil];
		}
		
		[machineProfileView setTitle:activeLocationObject.name];
		[machineProfileView setMachine:[displayArray objectAtIndex:indexPath.row]];
		[machineProfileView setLocation:activeLocationObject];
        
		[self.navigationController pushViewController:machineProfileView animated:YES];
	}	
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	tempMachineDict = [[NSMutableDictionary alloc] initWithCapacity:activeLocationObject.totalMachines];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"machine"]) {
		isBuildingMachine = YES;
		tempMachineObject = [[Machine alloc] init];
		tempMachineID = [[NSMutableString alloc] init];
		tempMachineName = [[NSMutableString alloc] init];
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
		if ([currentElement isEqualToString:@"name"])
            [tempMachineName appendString:string];
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
		[tempMachineObject setName:tempMachineName];
		[tempMachineObject setIdNumber:tempMachineID];
		[tempMachineObject setCondition:[Utils urlDecode:tempMachineCondition]];
		[tempMachineObject setDateAdded:tempMachineDateAdded];
		[tempMachineObject setConditionDate:tempMachineConditionDate];
		
        [tempMachineDict setObject:tempMachineObject forKey:tempMachineID];
		
		isBuildingMachine = NO;
	} else if ([elementName isEqualToString:@"street1"]) {
		[activeLocationObject setStreet1:currentStreet1];
	} else if ([elementName isEqualToString:@"street2"]) {
		[activeLocationObject setStreet2:currentStreet2];
	} else if ([elementName isEqualToString:@"state"]) {
		[activeLocationObject setState:currentState];
	} else if ([elementName isEqualToString:@"city"]) {
		[activeLocationObject setCity:currentCity];
	} else if ([elementName isEqualToString:@"zip"]) {
		[activeLocationObject setZip:currentZip];
	} else if ([elementName isEqualToString:@"phone"]) {
		[activeLocationObject setPhone:currentPhone];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[activeLocationObject setIsLoaded:YES];
	[activeLocationObject setMachines:tempMachineDict];
	[activeLocationObject setTotalMachines:[tempMachineDict count]];
	
	[self refreshPage];
	
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if(parsingAttempts < 15) {
		parsingAttempts++;
		[self loadLocationData];
	} else {
		UIApplication* app = [UIApplication sharedApplication];
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