#import "EventsViewController.h"
#import "PBMDoubleTableCell.h"
#import "Utils.h"

@implementation EventsViewController
@synthesize sectionTitles, sectionArray, eventProfileViewController, weekdayTitles, noEventsLabel;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {    
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	noEventsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
	[noEventsLabel setText:@"(no upcoming events)"];
	[noEventsLabel setBackgroundColor:[UIColor blackColor]];
	[noEventsLabel setTextColor:[UIColor whiteColor]];
	[noEventsLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[noEventsLabel setTextAlignment:UITextAlignmentCenter];
	
	weekdayTitles = [[NSArray alloc] initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"Events"];
    
	[self refreshPage];
	[super viewWillAppear:animated];
}

- (void)refreshPage {    
	if(appDelegate.activeRegion.events == nil) {
		[noEventsLabel removeFromSuperview];
		[self showLoaderIconLarge];
	} else if([appDelegate.activeRegion.events count] == 0) {
		[self.tableView setSeparatorColor:[UIColor blackColor]];
		[self.view addSubview:noEventsLabel];
	} else {
		[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
		[noEventsLabel removeFromSuperview];
	}

	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	if (appDelegate.activeRegion.events == nil) {		
		sectionTitles = [[NSMutableArray alloc] initWithObjects:@"featured", @"tournaments", @"other", @"past events", nil];
		sectionArray = [[NSMutableArray alloc] initWithCapacity:[sectionTitles count]];
		
		for (int i = 0; i < [sectionTitles count]; i++) {
			[sectionArray addObject:[[NSMutableArray alloc] init]];
		}
        	
		@autoreleasepool {
			[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:[NSString stringWithFormat:@"%@init=3",appDelegate.rootURL]];
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
        [appDelegate saveContext];
		
		int difference = [event.endDate isEqual:@""] ? 3 : [self differenceInDaysFrom:[NSDate date] to:event.endDate];
		int index;
		
		if(difference <= 0) {
			if([event.categoryNo intValue] == 2) index = 0;
			if([event.categoryNo intValue] == 1) index = 1;
			if([event.categoryNo intValue] == 3) index = 2;
		} else {
			index = 3;
		}
            
		[[sectionArray objectAtIndex:index] addObject:event];
	}
    
	currentElement = @"";
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (![string isEqualToString:@"\n"]) {
        if ([currentElement isEqualToString:@"name"])       
            [currentName appendString:string];
		
        if ([currentElement isEqualToString:@"link"])       
            [currentLink appendString:string];
		
        if ([currentElement isEqualToString:@"categoryNo"]) 
            currentCategoryNo = [NSNumber numberWithInt:[string intValue]];
        
        if ([currentElement isEqualToString:@"locationNo"]) 
            currentLocationID = [NSNumber numberWithInt:[string intValue]];

        if ([currentElement isEqualToString:@"longDesc"])   
            [currentLongDesc appendString:string];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        if ([currentElement isEqualToString:@"startDate"]) {  
            currentStartDate = [formatter dateFromString:string];
        }
        if ([currentElement isEqualToString:@"endDate"]) {  
            currentEndDate = [formatter dateFromString:string];
        }
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSSortDescriptor *distanceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES selector:@selector(compare:)];
	
	for(int i = [sectionArray count] - 1; i >= 0 ; i--) {
		NSMutableArray *array = (NSMutableArray*) [sectionArray objectAtIndex:i];
		
		if([array count] > 0) {
			if (i == [sectionArray count] - 1) {
				distanceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO selector:@selector(compare:)];
			} else { 
				distanceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES selector:@selector(compare:)];
			}
                
			[array sortUsingDescriptors:[NSArray arrayWithObjects:distanceSortDescriptor, nil]];
		} else {
			[sectionTitles removeObjectAtIndex:i];
			[sectionArray removeObjectAtIndex:i];
		}
	}
	
	[appDelegate.activeRegion setEvents:[NSSet setWithArray:sectionArray]];
		
	[super parserDidEndDocument:parser];
	[self refreshPage];
}

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:toDate toDate:startDate options:0];
    
    return [components day];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [appDelegate.activeRegion.events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	    
    return [appDelegate.activeRegion.events count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {	
	return [sectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:@"DoubleTextCellID"];
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
	
	if(eventProfileViewController == nil) {
		eventProfileViewController = [[EventProfileViewController alloc] initWithNibName:@"EventProfileView" bundle:nil];
	}
    
	[eventProfileViewController setEvent:event];
	
    [self.navigationController pushViewController:eventProfileViewController animated:YES];
}

- (void)dealloc {
	[noEventsLabel reloadInputViews];
}

@end