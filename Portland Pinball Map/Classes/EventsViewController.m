#import "EventsViewController.h"
#import "PBMDoubleTableCell.h"
#import "Utils.h"

@implementation EventsViewController
@synthesize sectionTitles, sectionArray, today, eventProfile, weekdayTitles, noEventsLabel;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {    
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	noEventsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
	[noEventsLabel setText:@"(no upcoming events)"];
	[noEventsLabel setBackgroundColor:[UIColor blackColor]];
	[noEventsLabel setTextColor:[UIColor whiteColor]];
	[noEventsLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[noEventsLabel setTextAlignment:UITextAlignmentCenter];
	
	weekdayTitles = [[NSArray alloc] initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday",nil];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"Events"];
    
	[self refreshPage];
	[super viewWillAppear:animated];
}

- (void)refreshPage {    
	if(appDelegate.activeRegion.eventArray == nil) {
		[noEventsLabel removeFromSuperview];
		[self showLoaderIconLarge];
	} else if([appDelegate.activeRegion.eventArray count] == 0) {
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

	if (appDelegate.activeRegion.eventArray == nil) {
		today = [[NSDate alloc] init];
		
		sectionTitles = [[NSMutableArray alloc] initWithObjects:@"featured", @"tournaments", @"other", @"past events",nil];
		sectionArray = [[NSMutableArray alloc] initWithCapacity:[sectionTitles count]];
		
		for (int i = 0; i < [sectionTitles count]; i++) {
			NSMutableArray *array = [[NSMutableArray alloc] init];
			[sectionArray addObject:array];
		}
        
		NSString *path = [NSString stringWithFormat:@"%@init=3",appDelegate.rootURL];
	
		@autoreleasepool {
			[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"event"]) {
        eventObject = [[Event alloc] init];
		currentID = [[NSMutableString alloc] init];
		currentName = [[NSMutableString alloc] init];
		currentLongDesc = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentCategoryNo = [[NSMutableString alloc] init];
		currentStartDate = [[NSMutableString alloc] init];
		currentEndDate = [[NSMutableString alloc] init];
		currentLocationNo = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {	
	if ([elementName isEqualToString:@"event"]) {		
		[eventObject setIdNumber:currentID];
		[eventObject setName:currentName];
		[eventObject setLongDesc:currentLongDesc];
		[eventObject setLink:currentLink];
		[eventObject setCategoryNo:currentCategoryNo];
		[eventObject setStartDate:currentStartDate];
		[eventObject setEndDate:currentEndDate];
		[eventObject setLocationNo:currentLocationNo];
		
		Location *location = (Location *)[appDelegate.activeRegion.locations objectForKey:currentLocationNo];
		[eventObject setLocation:location];
		[eventObject setDisplayName:[currentName isEqualToString:@""] ? location.name : currentName];
				
		NSMutableString *displayDate = [[NSMutableString alloc] initWithString:[Utils formatDateFromString:currentStartDate]];
		
		NSDate *endDate;
		if(![currentEndDate isEqualToString:@""] && ![currentEndDate isEqualToString:currentStartDate]) {
			endDate = [Utils getDateFromString:currentEndDate];
			NSString *appendString = [NSString stringWithFormat:@" to %@",[Utils formatDateFromString:currentEndDate]];
            
			[displayDate appendString:appendString];
		} else {
			endDate = [Utils getDateFromString:currentStartDate];
		}
            
		[eventObject setDisplayDate:displayDate];
		
		int difference = [endDate isEqual:@""] ? 3 : [self differenceInDaysFrom:today to:endDate];
		int index;
		
		if(difference <= 0) {
			if([eventObject.categoryNo isEqualToString:@"2"]) index = 0;
			if([eventObject.categoryNo isEqualToString:@"1"]) index = 1;
			if([eventObject.categoryNo isEqualToString:@"3"]) index = 2;
		} else {
			index = 3;
		}
            
		NSMutableArray *quickArray = [sectionArray objectAtIndex:index];
		[quickArray addObject:eventObject];

	}
    
	currentElement = @"";
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (![string isEqualToString:@"\n"]) {
		if ([currentElement isEqualToString:@"id"])         
            [currentID appendString:string];
		
        if ([currentElement isEqualToString:@"name"])       
            [currentName appendString:string];
		
        if ([currentElement isEqualToString:@"link"])       
            [currentLink appendString:string];
		
        if ([currentElement isEqualToString:@"categoryNo"]) 
            [currentCategoryNo appendString:string];
		
        if ([currentElement isEqualToString:@"startDate"])  
            [currentStartDate appendString:string];
		
        if ([currentElement isEqualToString:@"endDate"])    
            [currentEndDate appendString:string];
        
		if ([currentElement isEqualToString:@"locationNo"]) 
            [currentLocationNo appendString:string];
	}
    
	if ([currentElement isEqualToString:@"longDesc"])   
        [currentLongDesc appendString:string];
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
	
	[appDelegate.activeRegion setEventArray:sectionArray];
	[appDelegate.activeRegion setEventTitles:sectionTitles];
		
	[super parserDidEndDocument:parser];
	[self refreshPage];
}

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:toDate toDate:startDate options:0];
    
    return [components day];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [appDelegate.activeRegion.eventArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.eventArray objectAtIndex:section];
    
    return [locationGroup count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {	
	return [appDelegate.activeRegion.eventTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }

	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.eventArray objectAtIndex:section];
	Event *item2 = (Event *)[locationGroup objectAtIndex:row];
	
	[cell.nameLabel setText:item2.displayName];
	[cell.subLabel setText:item2.displayDate];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.eventArray objectAtIndex:section];
	Event *eventObj = (Event *)[locationGroup objectAtIndex:row];
	
	if(eventProfile == nil) {
		eventProfile = [[EventProfileViewController alloc] initWithNibName:@"EventProfileView" bundle:nil];
	}
    
	[eventProfile setEventObject:eventObj];
	
    [self.navigationController pushViewController:eventProfile animated:YES];
}

- (void)dealloc {
	[noEventsLabel reloadInputViews];
}

@end