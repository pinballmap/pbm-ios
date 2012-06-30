#import "EventProfileViewController.h"
#import "PBMDoubleTableCell.h"
#import "Utils.h"
#import "EventsViewController.h"

@implementation EventsViewController
@synthesize sectionData;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {    
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"Events"];
	[self refreshPage];
    
	[super viewWillAppear:animated];
}

- (void)refreshPage {    
	if (appDelegate.activeRegion.events == nil) {
		[self showLoaderIconLarge];
	} else if ([appDelegate.activeRegion.events count] == 0) {
		[self.tableView setSeparatorColor:[UIColor blackColor]];
	} else {
		[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
	}
    
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	if (appDelegate.activeRegion.events == nil || [appDelegate.activeRegion.events count] == 0) {
		sectionData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSMutableArray alloc] init], FEATURED, [[NSMutableArray alloc] init], TOURNAMENTS, [[NSMutableArray alloc] init], OTHER, [[NSMutableArray alloc] init], PAST_EVENTS, nil];
        	
		@autoreleasepool {
            [self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:[NSString stringWithFormat:@"%@init=3", appDelegate.rootURL]];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"event"]) {
		currentID = [[NSNumber alloc] init];
		currentName = [[NSMutableString alloc] init];
		currentLongDesc = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentCategoryNo = [[NSNumber alloc] init];
		currentStartDate = [[NSDate alloc] init];
		currentEndDate = [[NSDate alloc] init];
		currentLocationID = [[NSNumber alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {	
	if ([elementName isEqualToString:@"event"]) {
        Location *location = (Location *)[appDelegate fetchObject:@"Location" where:@"idNumber" equals:[NSString stringWithFormat:@"%d", [currentLocationID intValue]]];

        Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:appDelegate.managedObjectContext];
		[event setName:currentName];
		[event setLongDesc:currentLongDesc];
		[event setExternalLink:currentLink];
		[event setCategoryNo:currentCategoryNo];
		[event setStartDate:currentStartDate];
		[event setEndDate:currentEndDate];
		[event setLocation:location];
        [appDelegate.activeRegion addEventsObject:event];
        [location addEventsObject:event];
        [appDelegate saveContext];
		
		int difference = [event.endDate isEqual:@""] ? 3 : [self differenceInDaysFrom:[NSDate date] to:event.endDate];
		NSString *index;

		if(difference <= 0) {
			if([event.categoryNo intValue] == 2) {
                index = FEATURED;
            } else if([event.categoryNo intValue] == 1) {
                index = TOURNAMENTS;
            } else if ([event.categoryNo intValue] == 3) {
                index = OTHER;
            } else {
                index = PAST_EVENTS;    
            }
		} else {
			index = PAST_EVENTS;
		}

		[[sectionData valueForKey:index] addObject:event];
	}
    
	currentElement = @"";
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (![string isEqualToString:@"\n"]) {
        if ([currentElement isEqualToString:@"name"])       
            [currentName appendString:string];		
        if ([currentElement isEqualToString:@"link"])       
            [currentLink appendString:string];
        if ([currentElement isEqualToString:@"longDesc"])   
            [currentLongDesc appendString:string];
		
        if ([currentElement isEqualToString:@"categoryNo"]) 
            currentCategoryNo = [NSNumber numberWithInt:[string intValue]];
        if ([currentElement isEqualToString:@"locationNo"]) 
            currentLocationID = [NSNumber numberWithInt:[string intValue]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        if ([currentElement isEqualToString:@"startDate"])
            currentStartDate = [formatter dateFromString:string];
        if ([currentElement isEqualToString:@"endDate"])
            currentEndDate = [formatter dateFromString:string];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	for (NSString *key in sectionData.allKeys) {
		NSMutableArray *data = [sectionData valueForKey:key];
                                
		if ([data count] > 0) {
            [sectionData setValue:(NSMutableArray *)[data sortedArrayUsingComparator:^NSComparisonResult(Event *a, Event *b) {
                return [b.startDate compare:a.startDate];
            }]  forKey:key];            
		} else {
            [sectionData removeObjectForKey:key];
		}
	}
			
	[super parserDidEndDocument:parser];
	[self refreshPage];
}

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:toDate toDate:startDate options:0];
    
    return [components day];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionData.allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
    NSString *index = [sectionData.allKeys objectAtIndex:section];
        
    return [[sectionData valueForKey:index] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
    return [sectionData.allKeys objectAtIndex:section];    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell *)[tableView dequeueReusableCellWithIdentifier:@"DoubleTextCellID"];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }

	NSUInteger row = [indexPath row];
	Event *event = [appDelegate.activeRegion.events.allObjects objectAtIndex:row];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-mm-dd"];
    NSMutableString *displayDate = [[NSMutableString alloc] initWithString:[Utils formatDateFromString:[formatter stringFromDate:event.startDate]]];
    
    if(!(event.endDate == nil) && !([event.endDate compare:event.startDate] == NSOrderedSame)) {
        NSString *appendString = [NSString stringWithFormat:@" to %@", [Utils formatDateFromString:[formatter stringFromDate:event.endDate]]];
        
        [displayDate appendString:appendString];
    }
        
	[cell.nameLabel setText:[event.name isEqualToString:@""] ? event.location.name : event.name];
	[cell.subLabel setText:displayDate];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	Event *event = (Event *)[appDelegate.activeRegion.events.allObjects objectAtIndex:row];
	
    EventProfileViewController *eventProfileViewController = [[EventProfileViewController alloc] initWithNibName:@"EventProfileView" bundle:nil];
	[eventProfileViewController setEvent:event];
	
    [self.navigationController pushViewController:eventProfileViewController animated:YES];
}

@end