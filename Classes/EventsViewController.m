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
        
        dispatch_async(kBgQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@events.json", appDelegate.rootURL]]];
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        });        
	}
}

- (void)fetchedData:(NSData *)data {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray *events = json[@"events"];
    for (NSDictionary *eventContainer in events) {
        NSDictionary *eventData = eventContainer[@"event"];

        NSString *categoryNo = eventData[@"categoryNo"];
        NSString *locationNo = eventData[@"locationNo"];
        NSString *endDate = eventData[@"endDate"];
        NSString *startDate = eventData[@"startDate"];
        NSString *link = eventData[@"link"] == (NSString *)[NSNull null] ? @"" : eventData[@"link"];
        
        Location *location = NULL;
        if (locationNo != (NSString *)[NSNull null]) {
            location = (Location *)[appDelegate fetchObject:@"Location" where:@"idNumber" equals:[NSString stringWithFormat:@"%d", [locationNo intValue]]];
        }
                    
        Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:appDelegate.managedObjectContext];
		[event setName:eventData[@"name"]];
		[event setLongDesc:eventData[@"longDesc"]];
		[event setExternalLink:link];
        [event setCategoryNo:(categoryNo == (NSString *)[NSNull null] ? NULL : @([categoryNo intValue]))];
		[event setStartDate:(startDate == (NSString *)[NSNull null]) ? NULL : [formatter dateFromString:startDate]];
		[event setEndDate:(endDate == (NSString *)[NSNull null]) ? NULL : [formatter dateFromString:endDate]];
		[event setLocation:location];
        [appDelegate.activeRegion addEventsObject:event];
        [location addEventsObject:event];
        [appDelegate saveContext];
		
		int difference = event.endDate == nil ? 3 : [self differenceInDaysFrom:[NSDate date] to:event.endDate];
		NSString *index;
        
		if (difference <= 0) {
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
	Event *event = appDelegate.activeRegion.events.allObjects[row];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-mm-dd"];
    
    NSMutableString *displayDate = [[NSMutableString alloc] init];
    
    if (event.startDate != nil) {
        [displayDate appendString:[formatter stringFromDate:event.startDate]];
    }
        
    if(!(event.endDate == nil) && !([event.endDate compare:event.startDate] == NSOrderedSame)) {
        NSString *appendString = [NSString stringWithFormat:@" to %@", [formatter stringFromDate:event.endDate]];
        
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