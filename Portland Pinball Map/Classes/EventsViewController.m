#import "EventsViewController.h"
#import "PPMDoubleTableCell.h"

@implementation EventsViewController
@synthesize sectionTitles, sectionArray, today, eventProfile, weekdayTitles, noEventsLabel;

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		dayRange.location = 8;
		dayRange.length = 2;
		
		monthRange.location = 5;
		monthRange.length = 2;
		
		yearRange.location = 0;
		yearRange.length = 4;
		
	}
    
	return self;
}

- (void)viewDidLoad {
	self.title = @"Events";
	
	noEventsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
	noEventsLabel.text = @"(no upcoming events)";
	noEventsLabel.backgroundColor = [UIColor blackColor];
	noEventsLabel.textColor       = [UIColor whiteColor];
	noEventsLabel.font            = [UIFont boldSystemFontOfSize:20];
	noEventsLabel.textAlignment   = UITextAlignmentCenter;
	
	weekdayTitles = [[NSArray alloc] initWithObjects:@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",nil];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = @"Events";
	[self refreshPage];
	[super viewWillAppear:animated];
}

- (void)refreshPage {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	if(appDelegate.activeRegion.eventArray == nil) {
		[noEventsLabel removeFromSuperview];
		[self showLoaderIconLarge];
	} else if([appDelegate.activeRegion.eventArray count] == 0) {
		self.tableView.separatorColor = [UIColor blackColor];
		[self.view addSubview:noEventsLabel];
	} else {
		self.tableView.separatorColor = [UIColor darkGrayColor];
		[noEventsLabel removeFromSuperview];
	}

	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.activeRegion.eventArray == nil) {
		today = [[NSDate alloc] init];
		
		sectionTitles = [[NSMutableArray alloc] initWithObjects:@"featured",@"tournaments",@"other",@"past events",nil];
		sectionArray = [[NSMutableArray alloc] initWithCapacity:[sectionTitles count]];
		
		for(int i = 0; i < [sectionTitles count] ; i++) {
			NSMutableArray *array = [[NSMutableArray alloc] init];
			[sectionArray addObject:array];
		}
		NSString * path;
		
		if ([appDelegate.activeRegion.subdir isEqualToString:@""]) {
			path = [NSString stringWithFormat:@"http://pinballmap.com/iphone.html?init=3"]; // special case for Portland
		} else {
			path = [NSString stringWithFormat:@"http://pinballmap.com/%@/iphone.html?init=3",appDelegate.activeRegion.subdir,appDelegate.activeRegion.subdir];
        }
	
		@autoreleasepool {
			[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
		}
	}
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"event"]) {
        eventObject = [[EventObject alloc] init];
		current_id = [[NSMutableString alloc] initWithString:@""];
		current_name = [[NSMutableString alloc] initWithString:@""];
		current_longDesc = [[NSMutableString alloc] initWithString:@""];
		current_link = [[NSMutableString alloc] initWithString:@""];
		current_categoryNo = [[NSMutableString alloc] initWithString:@""];
		current_startDate = [[NSMutableString alloc] initWithString:@""];
		current_endDate = [[NSMutableString alloc] initWithString:@""];
		current_locationNo = [[NSMutableString alloc] initWithString:@""];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {	
	if ([elementName isEqualToString:@"event"]) {
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		eventObject.id_number  = current_id;
		eventObject.name       = current_name;
		eventObject.longDesc   = current_longDesc;
		eventObject.link       = current_link;
		eventObject.categoryNo = current_categoryNo;
		eventObject.startDate  = current_startDate;
		eventObject.endDate    = current_endDate;
		eventObject.locationNo = current_locationNo;
		
		LocationObject *location = (LocationObject *)[appDelegate.activeRegion.locations objectForKey:current_locationNo];
		eventObject.location = location;
		
		NSString *displayName;
		if([current_name isEqualToString:@""])
			displayName = [NSString stringWithString:location.name];
		else 
			displayName = [NSString stringWithString:current_name];
		
		eventObject.displayName = displayName;
				
		NSMutableString *displayDate = [[NSMutableString alloc] initWithString:[self formatDate:current_startDate]];
		
		NSDate *endDate;
		if(![current_endDate isEqualToString:@""] && ![current_endDate isEqualToString:current_startDate]) {
			endDate = [self getDateFromString:current_endDate];
			NSString *appendString = [NSString stringWithFormat:@" to %@",[self formatDate:current_endDate]];
			[displayDate appendString:appendString];
		} else {
			endDate = [self getDateFromString:current_startDate];
		}
            
		eventObject.displayDate = displayDate;
		
		int difference = [self differenceInDaysFrom:today to:endDate];
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
	if(![string isEqualToString:@"\n"]) {
		if ([currentElement isEqualToString:@"id"])         
            [current_id appendString:string];
		
        if ([currentElement isEqualToString:@"name"])       
            [current_name appendString:string];
		
        if ([currentElement isEqualToString:@"link"])       
            [current_link appendString:string];
		
        if ([currentElement isEqualToString:@"categoryNo"]) 
            [current_categoryNo appendString:string];
		
        if ([currentElement isEqualToString:@"startDate"])  
            [current_startDate appendString:string];
		
        if ([currentElement isEqualToString:@"endDate"])    
            [current_endDate appendString:string];
        
		if ([currentElement isEqualToString:@"locationNo"]) 
            [current_locationNo appendString:string];
	}
    
	if ([currentElement isEqualToString:@"longDesc"])   
        [current_longDesc appendString:string];
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
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.activeRegion.eventArray = sectionArray;
	appDelegate.activeRegion.eventTitles = sectionTitles;
	
	
	[super parserDidEndDocument:parser];
	[self refreshPage];
}

- (void)viewDidUnload {
	noEventsLabel = nil;	
}

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                fromDate:toDate
                                                  toDate:startDate
                                                 options:0];
    NSInteger days = [components day];
    return days;
}

- (NSDate *)getDateFromString:(NSString *)dateString {
	NSString *day   = [[NSString alloc] initWithString:[dateString substringWithRange:dayRange]];
	NSString *year  = [[NSString alloc] initWithString:[dateString substringWithRange:yearRange]];
	NSString *month = [[NSString alloc] initWithString:[dateString substringWithRange:monthRange]];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *returnDate = [inputFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",year,month,day]];
	
	
	return returnDate;
}

-(NSString *)formatDate:(NSString*)dateString {
	NSString *year  = [[NSString alloc] initWithString:[dateString substringWithRange:yearRange]];

	NSString *month = [[NSString alloc] initWithString:[dateString substringWithRange:monthRange]];
	NSString *displayMonth;
	
	if ([month isEqualToString:@"01"]) {
        displayMonth = [[NSString alloc] initWithString:@"Jan"];
	} else if ([month isEqualToString:@"02"]) { 
        displayMonth = [[NSString alloc] initWithString:@"Feb"];
	} else if ([month isEqualToString:@"03"]) { 
        displayMonth = [[NSString alloc] initWithString:@"March"];
	} else if ([month isEqualToString:@"04"]) { 
        displayMonth = [[NSString alloc] initWithString:@"April"];
	} else if ([month isEqualToString:@"05"]) { 
        displayMonth = [[NSString alloc] initWithString:@"May"];
	} else if ([month isEqualToString:@"06"]) { 
        displayMonth = [[NSString alloc] initWithString:@"June"];
	} else if ([month isEqualToString:@"07"]) { 
        displayMonth = [[NSString alloc] initWithString:@"July"];
	} else if ([month isEqualToString:@"08"]) { 
        displayMonth = [[NSString alloc] initWithString:@"Aug"];
	} else if ([month isEqualToString:@"09"]) { 
        displayMonth = [[NSString alloc] initWithString:@"Sep"];
	} else if ([month isEqualToString:@"10"]) { 
        displayMonth = [[NSString alloc] initWithString:@"Oct"];
	} else if ([month isEqualToString:@"11"]) { 
        displayMonth = [[NSString alloc] initWithString:@"Nov"];
	} else {
        displayMonth = [[NSString alloc] initWithString:@"Dec"];
    }
	
	NSRange digit;
    digit.length = 1;
    digit.location = 1;
	
	NSString *day = [[NSString alloc] initWithString:[dateString substringWithRange:dayRange]];
	NSString *lastDigit = [[NSString alloc] initWithString:[day substringWithRange:digit]];
	NSString *extra;
	 
	if ([day isEqualToString:@"11"]) {      
        extra = [[NSString alloc] initWithString:@"th"];
	} else if ([day isEqualToString:@"12"]) {      
        extra = [[NSString alloc] initWithString:@"th"];
	} else if ([day isEqualToString:@"13"]) {      
        extra = [[NSString alloc] initWithString:@"th"];
	} else if ([lastDigit isEqualToString:@"1"]) { 
        extra = [[NSString alloc] initWithString:@"st"];
	} else if ([lastDigit isEqualToString:@"2"]) { 
        extra = [[NSString alloc] initWithString:@"nd"];
	} else if ([lastDigit isEqualToString:@"3"]) { 
        extra = [[NSString alloc] initWithString:@"rd"];
	} else  {
        extra = [[NSString alloc] initWithString:@"th"];
    }
	
	NSString *dayString = [NSString stringWithFormat:@"%i%@",[day intValue],extra];
	
	
	NSDate *date = [self getDateFromString:dateString];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
	int weekday = [weekdayComponents weekday];
	NSString *weekdayString = [weekdayTitles objectAtIndex:weekday - 1];
	
	NSString *returnString = [[NSString alloc] initWithFormat:@"%@, %@ %@",weekdayString,displayMonth,dayString];
	
	
	return returnString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.activeRegion.eventArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.eventArray objectAtIndex:section];
    return [locationGroup count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	return [appDelegate.activeRegion.eventTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PPMDoubleTableCell *cell = (PPMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.eventArray objectAtIndex:section];
	EventObject *item2 = (EventObject *)[locationGroup objectAtIndex:row];
	
	cell.nameLabel.text = item2.displayName;
	cell.subLabel.text  = item2.displayDate;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.eventArray objectAtIndex:section];
	EventObject *eventObj = (EventObject *)[locationGroup objectAtIndex:row];
	
	if(eventProfile == nil) {
		eventProfile = [[EventProfileViewController alloc] initWithNibName:@"EventProfileView" bundle:nil];
	}
    
	eventProfile.eventObject = eventObj;
	[self.navigationController pushViewController:eventProfile animated:YES];
}

- (void)dealloc {
	[noEventsLabel reloadInputViews];
}

@end
