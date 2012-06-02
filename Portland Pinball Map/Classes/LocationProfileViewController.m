#import "Utils.h"
#import "LocationProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation LocationProfileViewController
@synthesize message, scrollView, mapLabel, mapButton, showMapButton, locationID, activeLocationObject, building_machine, label_holder, temp_machine_object, temp_machine_dict, temp_machine_name, temp_machine_id, temp_machine_condition, temp_machine_condition_date, temp_machine_dateAdded, lineView, mapView, addMachineButton, addMachineView, displayArray, machineProfileView;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.building_machine = NO;
	scrollView.contentSize = CGSizeMake(320,460);
	scrollView.maximumZoomScale = 1;
	scrollView.minimumZoomScale = 1;
	scrollView.clipsToBounds = YES;	
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return nil;
}

- (IBAction)addMachineButtonPressed:(id)sender {
	if(addMachineView == nil) {
		addMachineView = [[AddMachineViewController alloc] initWithNibName:@"AddMachineView" bundle:nil];
		addMachineView.title = @"Add a New Machine";
	}
	addMachineView.locationName = [NSString stringWithString:activeLocationObject.name];
	addMachineView.locationId   = [NSString stringWithString:activeLocationObject.id_number];
	addMachineView.location = self.activeLocationObject;
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
	NSLog(@"load location data");
	if (isParsing == NO && activeLocationObject.isLoaded == NO) {
			
		UIApplication* app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = YES;
    
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString *url = [[NSString alloc] initWithFormat:@"%@get_location=%@",appDelegate.rootURL,activeLocationObject.id_number];
		
		[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:url];
		[url release];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	[super viewWillDisappear:animated];
}

- (void)refreshPage {
	scrollView.contentOffset = CGPointMake(0, 0);
	self.title = activeLocationObject.name;
	
	(activeLocationObject.isLoaded) ? [self hideLoaderIconLarge] : [self showLoaderIconLarge];
	
	if(displayArray != nil) {
		displayArray = nil;
        [displayArray release];
	}
	
	displayArray = [[NSMutableArray alloc] initWithCapacity:activeLocationObject.totalMachines];
	
	for(id key in activeLocationObject.machines) {
		MachineObject *machineObject = (MachineObject *)[activeLocationObject.machines objectForKey:key];
		[displayArray addObject:machineObject];
	}
	
	NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)] autorelease];
	[displayArray sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	
	[self.tableView reloadData];
}

- (void)viewDidUnload {
	self.mapLabel  = nil;
	self.mapButton = nil;
	self.lineView  = nil;
	self.label_holder     = nil;
	self.addMachineButton = nil;
	self.loadingLabel = nil;
	self.activityView = nil;
	[super viewDidUnload];
}

- (void)dealloc {
	[machineProfileView release];
	
	[addMachineView release];
	[addMachineButton release];
	[lineView release];
	[mapView release];
	[activeLocationObject release];
	
	[current_street1 release];
	[current_street2 release];
	[current_city release];
	[current_state release];
	[current_zip release];
	[current_phone release];	
	
	[mapLabel release];
	[mapButton release];
	
	[mapURL release];
	[masterDictionary release];
	[info release];
	[scrollView release];
	
	[message release];
	
	[label_holder release];
	
	//XML Parsing
	[temp_machine_object release];
	[temp_machine_dict release];
	[temp_machine_id release];
	[temp_machine_name release];
	[temp_machine_condition release];
	[temp_machine_condition_date release];
	[temp_machine_dateAdded release];
	
	[displayArray release];
	
    [super dealloc];
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
	NSUInteger row     = [indexPath row];
	NSUInteger section = [indexPath section];
	
	if(section == 0 && row == 0) {
		static NSString *InfoCellID = @"LocationCellID";
		LocationProfileCell *cellA = (LocationProfileCell*)[tableView dequeueReusableCellWithIdentifier:InfoCellID];
		if (cellA == nil) {
			
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationProfileCellView" owner:self options:nil];
			
			for(id obj in nib) {
				if([obj isKindOfClass:[LocationProfileCell class]])
					cellA = (LocationProfileCell *)obj;
			}
		}
		
		if(activeLocationObject.isLoaded) {
			 NSString *addressStringA = [[NSString alloc] initWithFormat:@"%@ %@",activeLocationObject.street1,activeLocationObject.street2];
			 NSString *addressStringB = [[NSString alloc] initWithFormat:@"%@, %@ %@",activeLocationObject.city,activeLocationObject.state,activeLocationObject.zip];
			 cellA.addressLabel1.text = addressStringA;
			 cellA.addressLabel2.text = addressStringB;
			 cellA.phoneLabel.text = activeLocationObject.phone;
			 cellA.distanceLabel.text = [NSString stringWithFormat:@"≈ %@",activeLocationObject.distanceString];
										 
			 [addressStringA release];
			 [addressStringB release];
		} else {
			cellA.addressLabel1.text = @"";
			cellA.addressLabel2.text = @"";
			cellA.phoneLabel.text    = @"";
			cellA.distanceLabel.text = @"";
		}

		cellA.label.text = activeLocationObject.name;
		
		return cellA;
	} else {
		static NSString *CellIdentifier = @"SingleTextID";
		PPMTableCell *cell = (PPMTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
			cell = [self getTableCell];
		
		switch (section) {
			case 0:
				if(showMapButton && row == 1)
					cell.nameLabel.text = @"map";
				else if(showMapButton && row == 2)
					cell.nameLabel.text = @"add machine";
				else 
					cell.nameLabel.text = @"add machine";
				
				break;
			case 1:
			default:
				cell.nameLabel.text = [[displayArray objectAtIndex:row] name];
				break;
		}
		
		return cell;
	}
		
	return nil;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row     = [indexPath row];
	NSUInteger section = [indexPath section];
	
	if(section == 0 && row == 0)
		return 116.0f;
	
    return tv.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	switch (section) {
		case 0:
			return @"location";
			break;
		case 1:
		default:
			return @"machines";
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
	if(indexPath.section == 0) {
		if(showMapButton && row == 1) {
			if(mapView == nil) {
				mapView = [[LocationMap alloc] init];
				mapView.showProfileButtons = NO;
			}
			
			NSArray *quickArray = [[NSArray alloc] initWithObjects:activeLocationObject,nil];
			mapView.locationsToShow = quickArray;
			[quickArray release];
			
			mapView.title = activeLocationObject.name;
			
			[self.navigationController pushViewController:mapView animated:YES];
		} else {
			if(addMachineView == nil) {
				addMachineView = [[AddMachineViewController alloc] initWithNibName:@"AddMachineView" bundle:nil];
			}
			addMachineView.locationName = [NSString stringWithString:activeLocationObject.name];
			addMachineView.locationId   = [NSString stringWithString:activeLocationObject.id_number];
			addMachineView.location = self.activeLocationObject;
			[self.navigationController pushViewController:addMachineView animated:YES];
		}
	} else if(indexPath.section == 1) {
		if(machineProfileView == nil) {
			machineProfileView = [[MachineProfileViewController alloc] initWithNibName:@"MachineProfileView" bundle:nil];
		}
		
		machineProfileView.title = activeLocationObject.name;
		machineProfileView.machine = [displayArray objectAtIndex:indexPath.row];
		machineProfileView.location = activeLocationObject;
		[self.navigationController pushViewController:machineProfileView animated:YES];
	}	
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	temp_machine_dict = [[NSMutableDictionary alloc] initWithCapacity:activeLocationObject.totalMachines];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"machine"]) {
		building_machine = YES;
		temp_machine_object = [[MachineObject alloc] init];
		temp_machine_id = [[NSMutableString alloc] init];
		temp_machine_name = [[NSMutableString alloc] init];
		temp_machine_condition = [[NSMutableString alloc] init];
		temp_machine_dateAdded = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"condition"]) {
		temp_machine_condition_date = [[NSString alloc] initWithString:[attributeDict objectForKey:@"date"]];
	} else if ([elementName isEqualToString:@"street1"]) {
        current_street1 = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"street2"]) {
        current_street2	= [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"state"]) {
        current_state = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"city"]) {
        current_city = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"zip"]) {
        current_zip = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"phone"]) {
        current_phone = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(building_machine == YES) {
		if ([currentElement isEqualToString:@"id"])
            [temp_machine_id appendString:string];
		if ([currentElement isEqualToString:@"name"])
            [temp_machine_name appendString:string];
		if ([currentElement isEqualToString:@"condition"])
            [temp_machine_condition appendString:string];
		if ([currentElement isEqualToString:@"dateAdded"])
            [temp_machine_dateAdded appendString:string];
	} else {
		if ([currentElement isEqualToString:@"street1"])
            [current_street1 appendString:string];
		if ([currentElement isEqualToString:@"street2"])
            [current_street2 appendString:string];
		if ([currentElement isEqualToString:@"city"])
            [current_city appendString:string];
		if ([currentElement isEqualToString:@"state"])
            [current_state appendString:string];
		if ([currentElement isEqualToString:@"zip"])
            [current_zip appendString:string];
		if ([currentElement isEqualToString:@"phone"])
            [current_phone appendString:string];
	}

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	currentElement = @"";
	
	if ([elementName isEqualToString:@"machine"]) {
		temp_machine_object.name = temp_machine_name;
		temp_machine_object.id_number = temp_machine_id;
		temp_machine_object.condition = [LocationProfileViewController urlDecodeValue:temp_machine_condition];
		temp_machine_object.dateAdded = temp_machine_dateAdded;
		temp_machine_object.condition_date = temp_machine_condition_date;
		
        [temp_machine_dict setObject:temp_machine_object forKey:temp_machine_id];
		
		[temp_machine_object release];
		[temp_machine_id release];
		[temp_machine_name release];
		[temp_machine_condition release];
		[temp_machine_condition_date release];
		[temp_machine_dateAdded release];
		
		building_machine = NO;
	} else if ([elementName isEqualToString:@"street1"]) {
		activeLocationObject.street1 = current_street1;
		[current_street1 release];
	} else if ([elementName isEqualToString:@"street2"]) {
		activeLocationObject.street2 = current_street2;
		[current_street2 release];
	} else if ([elementName isEqualToString:@"state"]) {
		activeLocationObject.state = current_state;
		[current_state release];
	} else if ([elementName isEqualToString:@"city"]) {
		activeLocationObject.city = current_city;
		[current_city release];
	} else if ([elementName isEqualToString:@"zip"]) {
		activeLocationObject.zip = current_zip;
		[current_zip release];
	} else if ([elementName isEqualToString:@"phone"]) {
		activeLocationObject.phone = current_phone;
		[current_phone release];
	}
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
	activeLocationObject.isLoaded = YES;
	activeLocationObject.machines = temp_machine_dict;
	activeLocationObject.totalMachines = [temp_machine_dict count];
	
	[temp_machine_dict release];
	[self refreshPage];
	
	[super parserDidEndDocument:parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if(parsingAttempts < 15) {
		parsingAttempts++;
		[temp_machine_dict release];
		[self loadLocationData];
	} else {
		UIApplication* app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = NO;

		NSString * errorString = [NSString stringWithFormat:@"There was a problem loading this location. The developers have been notified. Please try again later.", [parseError code]];
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Whoops." 
														message:errorString 
														delegate:self 
														cancelButtonTitle:@"OK" 
														otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
		
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString* erstr = [NSString stringWithFormat:@"| CODE 0001 | %@ | %@ (%@) did not load",appDelegate.activeRegion.formalName, activeLocationObject.name,activeLocationObject.id_number];
		[Utils sendErrorReport:erstr];
	}
}


+ (NSString *)urlDecodeValue:(NSString *)str {
	NSString *result = (NSString *) CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, CFSTR(""));
	return [result autorelease];
}


+ (NSString *)urlencode:(NSString *) url {
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
													  @"@" , @"&" , @"=" , @"+" ,
													  @"$" , @"," , @"[" , @"]",
													  @"#", @"!", @"'", @"(", 
													  @")", @"*",@"'",@" ",@"|", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
													   @"%3A" , @"%40" , @"%26" ,
													   @"%3D" , @"%2B" , @"%24" ,
													   @"%2C" , @"%5B" , @"%5D", 
													   @"%23", @"%21", @"%27",
													   @"%28", @"%29", @"%2A",@"",@"%20",@"%7C", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++) {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
		
    return temp;
}

@end