#import "Utils.h"
#import "RecentAddition.h"
#import "RecentlyAddedViewController.h"

@implementation RecentlyAddedViewController
@synthesize sectionTitles, sectionData;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

    [super viewDidLoad];
}
 
- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:@"Recently Added"];
	[self refreshPage];
    
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	if (appDelegate.activeRegion.recentAdditions == nil) {	
		sectionTitles = [[NSMutableArray alloc] initWithObjects:@"today", @"yesterday", @"this week", @"this month", @"this year", nil];
		sectionData = [[NSMutableArray alloc] initWithCapacity:[sectionTitles count]];
		
		for (NSString *sectionTitle in sectionTitles) {
			[sectionData addObject:[[NSMutableArray alloc] init]];
		}
        
		NSString *path = [NSString stringWithFormat:@"%@/%@/%@.rss", BASE_URL, appDelegate.activeRegion.subdir, @"location_machine_xrefs"];
            
		[self showLoaderIconLarge];
        
		@autoreleasepool {
			[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
		}
	}
	
	[self.tableView reloadData];
}

- (void)refreshPage {    
	if (appDelegate.activeRegion.recentAdditions == nil) {
		[self showLoaderIconLarge];
	}
	
	[self.tableView reloadData];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"item"]) {
		newMachineAtLocation = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDesc  = [[NSMutableString alloc] init];
		parsingItemNode = YES;
	}
}

- (NSDate *)getDateFromRegexMatches:(NSArray *)matches {
    NSString *day;
    NSString *year;
    NSString *monthText;
    
    for (NSTextCheckingResult *match in matches) {
        day = [currentDesc substringWithRange:[match rangeAtIndex:1]];
        monthText = [currentDesc substringWithRange:[match rangeAtIndex:2]];
        year = [currentDesc substringWithRange:[match rangeAtIndex:3]];
    }
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"LL"];
    NSDate *formattedMonth = [monthFormatter dateFromString:monthText];
        
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [inputFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@", year, [monthFormatter stringFromDate:formattedMonth], day]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"item"]) {
		parsingItemNode = NO;

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d\\d) (\\w\\w\\w) (\\d\\d\\d\\d)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:currentDesc options:0 range:NSMakeRange(0, [currentDesc length])];
        
        int difference;
		NSDate *dateAdded = nil;
		if ([matches count] > 0) {
            dateAdded = [self getDateFromRegexMatches:matches];
			difference = [Utils differenceInDaysFrom:[NSDate date] to:dateAdded];    
        } else {
			difference = DISTANT_FUTURE;
		}
        
		NSRange range = [currentTitle rangeOfString:@"was added to "];
		NSString *machineName = [currentTitle substringToIndex:range.location];
		NSString *locationName = [currentTitle substringFromIndex:range.length + range.location];
		
        Machine *machine = (Machine *)[appDelegate fetchObject:@"Machine" where:@"name" equals:machineName];
        Location *location = (Location *)[appDelegate fetchObject:@"Location" where:@"name" equals:locationName];
        LocationMachineXref *lmx = [LocationMachineXref findForMachine:machine andLocation:location];
        
        RecentAddition *recentAddition = [NSEntityDescription insertNewObjectForEntityForName:@"RecentAddition" inManagedObjectContext:appDelegate.managedObjectContext];
        [recentAddition setLocationMachineXref:lmx];
        [recentAddition setDateAdded:dateAdded];
		
		if(difference <= ONE_YEAR) {
            int index;
			if (difference == 0) {
                index = 0;
			} else if (difference == ONE_DAY) {
                index = 1;
			} else if (difference <=  ONE_WEEK) {
                index = 2;
			} else if (difference <=  ONE_MONTH) {
                index = 3;
			} else if (difference <=  ONE_YEAR) {
                index = 4;
            }
			
            [[sectionData objectAtIndex:index] addObject:recentAddition];
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
	
	for(int i = [sectionData count] - 1; i >= 0 ; i--) {
		NSMutableArray *array = (NSMutableArray *)[sectionData objectAtIndex:i];
		
		if ([array count] > 0) {
            [array sortUsingDescriptors:[NSArray arrayWithObjects:distanceSortDescriptor, nil]];
		} else {            
			[sectionTitles removeObjectAtIndex:i];
			[sectionData removeObjectAtIndex:i];
		}
	}
		
	[self.tableView reloadData];
	[self hideLoaderIconLarge];
	[super parserDidEndDocument:parser];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [appDelegate.activeRegion.recentAdditions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {   
	return [[sectionData objectAtIndex:section] count];    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {	
	return [sectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	    
    PBMDoubleTableCell *cell = (PBMDoubleTableCell*)[tableView dequeueReusableCellWithIdentifier:@"DoubleTextCellID"];
    if (cell == nil) {
		cell = [self getDoubleCell];
    }
	
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = [sectionData objectAtIndex:section];
	
    LocationMachineXref *lmx = [locationGroup objectAtIndex:row];
	[cell.nameLabel setText:lmx.machine.name];
	[cell.subLabel setText:lmx.location.name];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSArray *locationGroup = (NSArray *)[sectionData objectAtIndex:section];
    
    [self showLocationProfile:[locationGroup objectAtIndex:row]  withMapButton:YES];
}

@end