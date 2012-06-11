#import "RSSViewController.h"

@implementation RSSViewController
@synthesize sectionTitles, sectionArray, today;

Portland_Pinball_MapAppDelegate *appDelegate;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        dayRange.location = 9;
        dayRange.length = 2;
		 
        monthRange.location = 12;
        monthRange.length = 3;
		 
        yearRange.location = 16;
        yearRange.length = 4;
    }

    return self;
}

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

    [super viewDidLoad];
}
 
- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:@"Recently Added"];
	[self refreshPage];
    
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self setTitle:@"back"];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	if (appDelegate.activeRegion.rssArray == nil) {
		today = [[NSDate alloc] init];
		
		sectionTitles = [[NSMutableArray alloc] initWithObjects:@"today",@"yesterday",@"this week",@"this month",@"this year",nil];
		sectionArray = [[NSMutableArray alloc] initWithCapacity:[sectionTitles count]];
		
		for(int i = 0; i < [sectionTitles count] ; i++) {
			NSMutableArray *array = [[NSMutableArray alloc] init];
			[sectionArray addObject:array];
		}
        
		NSString *path = [NSString stringWithFormat:@"%@/%@/%@.rss", BASE_URL, appDelegate.activeRegion.subdir, appDelegate.activeRegion.subdir];
            
		[self showLoaderIconLarge];
        
		@autoreleasepool {
			[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
		}
	}
	
	[self.tableView reloadData];
}

- (void)refreshPage {    
	if (appDelegate.activeRegion.rssArray == nil) {
		[self showLoaderIconLarge];
	}
	
	[self.tableView reloadData];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"item"]) {
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDesc  = [[NSMutableString alloc] init];
		parsingItemNode = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"item"]) {
		parsingItemNode = NO;
		
		NSRange dateRangeCheck = [currentDesc rangeOfString:@"Added on"];
		
		NSString *dateID;
		int difference;
		if (dateRangeCheck.length > 0) {
			NSString *descText;
			if([currentDesc length] == 19) {
				descText = [[NSString alloc] initWithFormat:@"%@0%@", [currentDesc substringToIndex:9], [currentDesc substringFromIndex:9]];
			} else {
				descText = [currentDesc copy];
			}
            
			NSString *day = [[NSString alloc] initWithString:[descText substringWithRange:dayRange]];
			NSString *year = [[NSString alloc] initWithString:[descText substringWithRange:yearRange]];
			NSString *monthText = [[NSString alloc] initWithString:[descText substringWithRange:monthRange]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM"];
            NSDate *date = [dateFormatter dateFromString:monthText];
            
            NSString *monthID = [NSString stringWithFormat:@"%01d", [[dateFormatter stringFromDate:date] intValue]];
						
			NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
			[inputFormatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *addedDate = [inputFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",year,monthID,day]];
			
			difference = [self differenceInDaysFrom:today to:addedDate];
			
			dateID = [[NSString alloc] initWithFormat:@"%@%@%@",year,monthID,day];			
		} else {
			difference = 2000;
			dateID = [[NSString alloc] initWithString:@""];
		}

		NSString *string = [currentTitle copy];
		NSRange range = [string rangeOfString:@"was added to "];
		NSString *machineName = [[NSString alloc] initWithString:[string substringToIndex:range.location]];
		NSString *locationName = [[NSString alloc] initWithString:[string substringFromIndex:range.length + range.location]];
		
		[item setObject:dateID forKey:@"dateID"];
		[item setObject:machineName forKey:@"machine"];
		[item setObject:locationName forKey:@"location"];
		
		if(difference <= 365) {
			int index;
			if (difference == 0) {
                index = 0;
			} else if(difference == 1) {
                index = 1;
			} else if(difference <=  7) {
                index = 2;
			} else if(difference <=  31) {
                index = 3;
			} else if(difference <=  365) {
                index = 4;
            }
			
			NSMutableArray *quickArray = [sectionArray objectAtIndex:index];
			[quickArray addObject:item];
		}
		
	}
    
	currentElement = @"";
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(parsingItemNode == YES) {
		if ([currentElement isEqualToString:@"title"] && ![string isEqualToString:@"\n"]) {
			[currentTitle appendString:string];
		} else if ([currentElement isEqualToString:@"description"] && ![string isEqualToString:@"\n"]) {
			[currentDesc appendString:string];
        }
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSSortDescriptor *distanceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateID" ascending:NO selector:@selector(compare:)];
	
	for(int i = [sectionArray count] - 1; i >= 0 ; i--) {
		NSMutableArray *array = (NSMutableArray*) [sectionArray objectAtIndex:i];
		
		if([array count] > 0) {
            [array sortUsingDescriptors:[NSArray arrayWithObjects:distanceSortDescriptor, nil]];
		} else {
			[sectionTitles removeObjectAtIndex:i];
			[sectionArray removeObjectAtIndex:i];
		}
	}
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.activeRegion.rssArray = sectionArray;
	appDelegate.activeRegion.rssTitles = sectionTitles;
	
	
	[self.tableView reloadData];
	[self hideLoaderIconLarge];
	[super parserDidEndDocument:parser];
	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.activeRegion.rssArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
   
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.rssArray objectAtIndex:section];
    return [locationGroup count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSString *key = [appDelegate.activeRegion.rssTitles objectAtIndex:section];
	return key;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	static NSString *CellIdentifier = @"DoubleTextCellID";
    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.rssArray objectAtIndex:section];
	
	NSDictionary *item2 = (NSDictionary *)[locationGroup objectAtIndex:row];
	cell.nameLabel.text = [item2 objectForKey:@"machine"];
	cell.subLabel.text  = [item2 objectForKey:@"location"];
	return cell;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[appDelegate.activeRegion.rssArray objectAtIndex:section];
	NSDictionary *item2 = (NSDictionary *)[locationGroup objectAtIndex:row];
	NSString *locationName  = [item2 objectForKey:@"location"];
	
	for (id key in appDelegate.activeRegion.locations) {
		Location *loc = [appDelegate.activeRegion.locations objectForKey:key];
		
		if([locationName isEqualToString:loc.name]) {
			[self showLocationProfile:loc  withMapButton:YES];
			break;
		}
	} 
}


@end
