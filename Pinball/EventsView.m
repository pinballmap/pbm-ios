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

@interface EventsView () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResults;
    NSManagedObjectContext *managedContext;
}

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
    if ([[PinballMapManager sharedInstance] currentRegion]){
        [self updateRegion];
    }
    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(refreshRegion) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)refreshRegion{
    [[PinballMapManager sharedInstance] refreshRegion];
}
#pragma mark - Region Update
- (void)updateRegion{
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Events",[[[PinballMapManager sharedInstance] currentRegion] fullName]];
    managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
    fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                         managedObjectContext:managedContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    fetchedResults.delegate = self;
    [fetchedResults performFetch:nil];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[fetchedResults sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if ([[fetchedResults sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResults sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *currentEvent = [fetchedResults objectAtIndexPath:indexPath];
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
    Event *currentEvent = [fetchedResults objectAtIndexPath:indexPath];
    cell.textLabel.attributedText = currentEvent.eventTitle;
    cell.detailTextLabel.text = [currentEvent.startDate monthDayYearPretty:YES];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Event *currentEvent = [fetchedResults objectAtIndexPath:indexPath];
    EventProfileView *profileView = (EventProfileView *)[(UINavigationController *)[self.splitViewController detailViewForSplitView] navigationRootViewController];
    profileView.currentEvent = currentEvent;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"EventProfileView"]){
        Event *currentEvent = [fetchedResults objectAtIndexPath:[self.tableView indexPathForCell:sender]];
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
