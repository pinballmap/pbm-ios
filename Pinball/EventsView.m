//
//  EventsView.m
//  PinballMap
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "EventsView.h"
#import "NSDate+DateFormatting.h"
#import "EventProfileView.h"
#import "UIViewController+Helpers.h"
#import "GAAppHelper.h"
#import "ContactView.h"
#import "NSDate+CupertinoYankee.h"

@interface EventsView () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResults;
@property (nonatomic) NSManagedObjectContext *managedContext;

@property (weak) IBOutlet UISegmentedControl *eventSorter;


- (IBAction)suggestEvent:(id)sender;
@end

@implementation EventsView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRegion) name:@"RegionUpdate" object:nil];
    self.managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    [self.eventSorter setSelectedSegmentIndex:0];
    if ([[PinballMapManager sharedInstance] currentRegion]){
        [self updateRegion];
    }
    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(refreshRegion) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [GAAppHelper sendAnalyticsDataWithScreen:@"Events View"];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)refreshRegion{
    [[PinballMapManager sharedInstance] refreshRegion];
}
#pragma mark - Class Actions
- (IBAction)suggestEvent:(id)sender{
    ContactView *eventContact = (ContactView *)[[self.storyboard instantiateViewControllerWithIdentifier:@"ContactView"] navigationRootViewController];
    eventContact.contactType = ContactTypeEvent;
    [self.navigationController presentViewController:eventContact.parentViewController animated:YES completion:nil];
}
- (IBAction)changeEventSort:(id)sender{
    [self updateRegion];
}
#pragma mark - Region Update
- (void)updateRegion{
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Events",[[[PinballMapManager sharedInstance] currentRegion] fullName]];
    self.fetchedResults = nil;
    
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    // Do a check to see if today has any events.
    stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND (startDate >= %@ AND startDate <= %@)",[[[PinballMapManager sharedInstance] currentRegion] name],[[NSDate date] beginningOfDay],[[NSDate date] endOfDay]];
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
    NSArray *todayEvents = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:stackRequest error:nil];
    if (todayEvents.count == 0){
        // Remove the today segment since there are no events today.
        [self.eventSorter removeAllSegments];
        [self.eventSorter insertSegmentWithTitle:@"Upcoming" atIndex:0 animated:NO];
        [self.eventSorter setSelectedSegmentIndex:0];
        
        // Upcoming events only
        stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND startDate > %@",[[[PinballMapManager sharedInstance] currentRegion] name],[[NSDate date] endOfDay]];
        stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
    }else{
        // Reload the segment control since we have some events today and autoselect it.
        if (self.eventSorter.numberOfSegments == 1){
            [self.eventSorter removeAllSegments];
            [self.eventSorter insertSegmentWithTitle:@"Today" atIndex:0 animated:NO];
            [self.eventSorter insertSegmentWithTitle:@"Upcoming" atIndex:1 animated:NO];
            [self.eventSorter setSelectedSegmentIndex:0];
        }
        
        if (self.eventSorter.selectedSegmentIndex == 1){
            stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND startDate > %@",[[[PinballMapManager sharedInstance] currentRegion] name],[[NSDate date] endOfDay]];
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
        }
    }
    
    
    self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                         managedObjectContext:self.managedContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    self.fetchedResults.delegate = self;
    [self.fetchedResults performFetch:nil];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.fetchedResults sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if ([[self.fetchedResults sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *currentEvent = [self.fetchedResults objectAtIndexPath:indexPath];
    NSAttributedString *cellTitle = currentEvent.eventTitle;

    CGRect stringSize = [cellTitle boundingRectWithSize:CGSizeMake(270, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];//boundingRectWithSize:CGSizeMake(270, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];

    stringSize.size.height = stringSize.size.height+10;   // Take into account the 10 points of padding within a cell.
    if (stringSize.size.height+10 < 44){
        return 44;
    }else{
        return stringSize.size.height+10;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    Event *currentEvent = [self.fetchedResults objectAtIndexPath:indexPath];
    cell.textLabel.attributedText = currentEvent.eventTitle;
    cell.detailTextLabel.text = [currentEvent.startDate monthDayYearPretty:YES];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Event *currentEvent = [self.fetchedResults objectAtIndexPath:indexPath];
    EventProfileView *profileView = (EventProfileView *)[(UINavigationController *)[self.splitViewController detailViewForSplitView] navigationRootViewController];
    profileView.currentEvent = currentEvent;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"EventProfileView"]){
        Event *currentEvent = [self.fetchedResults objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        EventProfileView *profile = segue.destinationViewController;
        profile.currentEvent = currentEvent;
    }
}
#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

@end
