//
//  LocationsView.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationsView.h"
#import "Location.h"
#import "LocationProfileView.h"
#import "NewMachineLocationView.h"
#import "LocationProfileView-iPad.h"

@interface LocationsView () <NSFetchedResultsControllerDelegate,UIActionSheetDelegate,UISearchBarDelegate> {
    NSFetchedResultsController *fetchedResults;
    NSManagedObjectContext *managedContext;
    BOOL isSearching;
    NSMutableArray *searchResults;
    BOOL isClosets;
}

@end

@implementation LocationsView

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
    if ([[PinballManager sharedInstance] currentRegion]){
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
    [[PinballManager sharedInstance] refreshRegion];
}
- (void)setIsSelecting:(BOOL)isSelecting{
    _isSelecting = isSelecting;
    self.navigationItem.leftBarButtonItem = nil;
}
#pragma mark - Region Update
- (void)updateRegion{
    [self.refreshControl endRefreshing];
    isClosets = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Locations",[[[PinballManager sharedInstance] currentRegion] fullName]];
    managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballManager sharedInstance] currentRegion] name]];
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                         managedObjectContext:managedContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    fetchedResults.delegate = self;
    [fetchedResults performFetch:nil];
    [self.tableView reloadData];
}
#pragma mark - Searchbar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    isSearching = YES;
    searchBar.showsCancelButton = YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSFetchRequest *searchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    searchrequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ AND region.name = %@",searchText,[[[PinballManager sharedInstance] currentRegion] name]];
    [searchResults removeAllObjects];
    searchResults = nil;
    searchResults = [NSMutableArray new];
    NSError *error = nil;
    [searchResults addObjectsFromArray:[managedContext executeFetchRequest:searchrequest error:&error]];
    [self.tableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    isSearching = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
}
#pragma mark - Class
- (IBAction)filterResults:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Location Filter" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Location (Closest)",@"Number of Machines",@"Name",@"Zone",@"Location Type",nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"LocationProfileView"] && _isSelecting){
        return NO;
    }
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"LocationProfileView"]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Location *currentLocation;
        if (!isSearching){
            currentLocation = [fetchedResults objectAtIndexPath:indexPath];
        }else{
            currentLocation = [searchResults objectAtIndex:indexPath.row];
        }
        LocationProfileView *profile = segue.destinationViewController;
        profile.currentLocation = currentLocation;
    }
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        stackRequest.predicate = nil;
        isClosets = NO;
        NSString *sectionName;
        if (buttonIndex == 0){
            isClosets = YES;
            // Location
            NSArray *locations = [[[fetchedResults sections] lastObject] objects];
            [locations enumerateObjectsUsingBlock:^(Location *obj, NSUInteger idx, BOOL *stop) {
                [obj updateDistance];
            }];
            [[CoreDataManager sharedInstance] saveContext];
            locations = nil;
            stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballManager sharedInstance] currentRegion] name]];
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationDistance" ascending:YES]];
        }else if (buttonIndex == 1){
            // Number
            stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballManager sharedInstance] currentRegion] name]];
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"machineCount" ascending:NO]];
        }else if (buttonIndex == 2){
            // Name
            stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballManager sharedInstance] currentRegion] name]];
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        }else if (buttonIndex == 3){
            stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballManager sharedInstance] currentRegion] name]];
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"parentZone.name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            sectionName = @"parentZone.name";
        }else if (buttonIndex == 4){
            stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballManager sharedInstance] currentRegion] name]];
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationType.name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            sectionName = @"locationType.name";
        }
        
        fetchedResults = nil;
        fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                             managedObjectContext:managedContext
                                                               sectionNameKeyPath:sectionName
                                                                        cacheName:nil];
        fetchedResults.delegate = self;
        [fetchedResults performFetch:nil];
        [self.tableView reloadData];

    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!isSearching){
        return [[fetchedResults sections] count];
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (!isSearching){
        if ([[fetchedResults sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResults sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }
    }else{
        rows = searchResults.count;
    }
    return rows;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([[fetchedResults sections] count] > 1){
        NSString *sectionName = [[[fetchedResults sections] objectAtIndex:section] name];
        return sectionName;
    }
    return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Location *currentLocation;
    if (!isSearching){
        currentLocation = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentLocation = [searchResults objectAtIndex:indexPath.row];
    }
    NSString *cellTitle = currentLocation.name;
    
    CGRect stringSize = [cellTitle boundingRectWithSize:CGSizeMake(270, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
    
    stringSize.size.height = stringSize.size.height+10;   // Take into account the 10 points of padding within a cell.
    if (stringSize.size.height+10 < 44){
        return 44;
    }else{
        return stringSize.size.height+10;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    
    Location *currentLocation;
    if (!isSearching){
        currentLocation = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentLocation = [searchResults objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = currentLocation.name;
    if (isClosets){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f miles",[currentLocation.currentDistance floatValue]];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Machines: %lu",(unsigned long)currentLocation.machines.count];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Location *currentLocation;
    if (!isSearching){
        currentLocation = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentLocation = [searchResults objectAtIndex:indexPath.row];
    }

    if (_isSelecting){
        if ([_selectingViewController respondsToSelector:@selector(setLocation:)]){
            [_selectingViewController setLocation:currentLocation];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound){
        NSLog(@"%@",self.parentViewController);
        LocationProfileView_iPad *profileView = (LocationProfileView_iPad *)self.parentViewController;
        [profileView setCurrentLocation:currentLocation];
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
