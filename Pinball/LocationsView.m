//
//  LocationsView.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationsView.h"
#import "Location.h"
#import "LocationProfileView.h"
#import "NewMachineLocationView.h"
#import "LocationProfileView-iPad.h"
#import "MapView.h"
#import "UIViewController+Helpers.h"
#import "LocationCell.h"
#import "UIAlertView+Application.h"

@interface LocationsView () <NSFetchedResultsControllerDelegate,UIActionSheetDelegate,UISearchBarDelegate,UISearchDisplayDelegate> {
    UIActionSheet *filterSheet;
    UIActionSheet *closestSheet;
    
    NSFetchedResultsController *fetchedResults;
    NSManagedObjectContext *managedContext;

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
    if ([[PinballMapManager sharedInstance] currentRegion]){
        [self updateRegion];
    }
    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(refreshRegion) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LocationCell" bundle:nil] forCellReuseIdentifier:@"LocationCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"LocationCell" bundle:nil] forCellReuseIdentifier:@"LocationCell"];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)refreshRegion{
    [[PinballMapManager sharedInstance] refreshRegion];
}
- (void)setIsSelecting:(BOOL)isSelecting{
    _isSelecting = isSelecting;
    self.navigationItem.leftBarButtonItem = nil;
}
#pragma mark - Region Update
- (void)updateRegion{
    [self.refreshControl endRefreshing];
    isClosets = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[[[PinballMapManager sharedInstance] currentRegion] fullName]];
    managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
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
    searchBar.showsCancelButton = YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
}
#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSFetchRequest *searchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    searchrequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ AND region.name = %@",searchString,[[[PinballMapManager sharedInstance] currentRegion] name]];
    
    
    
    [searchResults removeAllObjects];
    searchResults = nil;
    searchResults = [NSMutableArray new];
    NSError *error = nil;
    [searchResults addObjectsFromArray:[managedContext executeFetchRequest:searchrequest error:&error]];

    return YES;
}
#pragma mark - Class Actions
- (IBAction)filterResults:(id)sender{
    filterSheet = [[UIActionSheet alloc] initWithTitle:@"Location Filter" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Distance",@"Number of Machines",@"Name",@"Zone",@"Location Type",nil];
    if ([UIDevice iPad]){
        [filterSheet showFromTabBar:self.tabBarController.tabBar];
    }else{
        [filterSheet addButtonWithTitle:@"Browse"];
        [filterSheet setCancelButtonIndex:[filterSheet addButtonWithTitle:@"Cancel"]];
        [filterSheet showFromTabBar:self.tabBarController.tabBar];
    }
}
- (IBAction)browseLocations:(id)sender{
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSArray *locations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:stackRequest error:nil];

    MapView *map = (MapView *)[(UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MapView"] navigationRootViewController];
    map.locations = locations;
    [self.navigationController presentViewController:map.parentViewController animated:YES completion:nil];
}
#pragma mark - Class
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"LocationProfileView"] && _isSelecting){
        return NO;
    }
    return YES;
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        if (actionSheet == filterSheet){
            NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
            stackRequest.predicate = nil;
            isClosets = NO;
            NSString *sectionName;
            if (buttonIndex == 0){
                if ([[PinballMapManager sharedInstance] userLocation]){
                    closestSheet = [[UIActionSheet alloc] initWithTitle:@"Distance" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 Mile", @"5 Miles", @"10 Miles", @"15 Miles", nil];
                    [closestSheet showFromTabBar:self.tabBarController.tabBar];
                }else{
                    [UIAlertView simpleApplicationAlertWithMessage:@"Location services are not enabled. Please enable to filter by distance." cancelButton:@"Ok"];
                }
                return;
            }else if (buttonIndex == 1){
                // Number
                stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
                stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"machineCount" ascending:NO]];
            }else if (buttonIndex == 2){
                // Name
                stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
                stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            }else if (buttonIndex == 3){
                stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
                stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"parentZone.name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
                sectionName = @"parentZone.name";
            }else if (buttonIndex == 4){
                stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
                stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationType.name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
                sectionName = @"locationType.name";
            }else if (buttonIndex == 5){
                [self browseLocations:nil];
                return;
            }
            
            fetchedResults = nil;
            fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                                 managedObjectContext:managedContext
                                                                   sectionNameKeyPath:sectionName
                                                                            cacheName:nil];
            fetchedResults.delegate = self;
            [fetchedResults performFetch:nil];
            [self.tableView reloadData];
        }else if (actionSheet == closestSheet){
            
            CLLocation *currentLocation = [[PinballMapManager sharedInstance] userLocation];
            isClosets = YES;
            // Logic from http://www.objc.io/issue-4/core-data-fetch-requests.html
            float distance;
            if (buttonIndex == 0){
                // 1 Mile
                distance = 1609.344*1.1;
            }else if (buttonIndex == 1){
                // 5 Miles
                distance = 8046.72*1.1;
            }else if (buttonIndex == 2){
                // 10 Miles
                distance = 16093.445*1.1;
            }else if (buttonIndex == 3){
                // 15 Miles
                distance = 24140.16*1.1;
            }
            
            double const earthRadius = 6371009.0;
            double meanLat = currentLocation.coordinate.latitude * M_PI / 180;
            double deltaLat = distance/earthRadius * 180 / M_PI;
            double deltaLong = distance/(earthRadius * cos(meanLat)) * 180 / M_PI;
            double minLat = currentLocation.coordinate.latitude - deltaLat;
            double maxLat = currentLocation.coordinate.latitude + deltaLat;
            double minLong = currentLocation.coordinate.longitude - deltaLong;
            double maxLong = currentLocation.coordinate.longitude +deltaLong;
            
            
            NSFetchRequest *locationFetch = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
            locationFetch.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND (%@ <= longitude) AND (longitude <= %@) AND (%@ <= latitude) AND (latitude <= %@)",[[[PinballMapManager sharedInstance] currentRegion] name],@(minLong),@(maxLong),@(minLat),@(maxLat)];
            locationFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
//            NSArray *items = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:locationFetch error:nil];

            fetchedResults = nil;
            fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:locationFetch
                                                                 managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
            fetchedResults.delegate = self;
            [fetchedResults performFetch:nil];
            [self.tableView reloadData];
        }
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.tableView){
        return [[fetchedResults sections] count];
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (tableView == self.tableView){
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
    if (tableView == self.tableView){
        currentLocation = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentLocation = [searchResults objectAtIndex:indexPath.row];
    }
    NSString *cellTitle = currentLocation.name;
    
    CGRect stringSize = [cellTitle boundingRectWithSize:CGSizeMake(230, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
    
    stringSize.size.height = stringSize.size.height+10;   // Take into account the 10 points of padding within a cell.
    if (stringSize.size.height+10 < 44){
        return 44;
    }else{
        return stringSize.size.height+10;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LocationCell *cell;
    
    if (tableView == self.tableView){
        cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    }
    
    Location *currentLocation;
    if (tableView == self.tableView){
        currentLocation = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentLocation = [searchResults objectAtIndex:indexPath.row];
    }
    cell.locationName.text = currentLocation.name;

    if ([currentLocation.currentDistance isEqual:@(0)]){
        cell.locationDetail.text = [NSString stringWithFormat:@"%@, %@",currentLocation.street,currentLocation.city];
    }else{
        cell.locationDetail.text = [NSString stringWithFormat:@"%.02f miles",[currentLocation.currentDistance floatValue]];
    }
    
    cell.machineCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)currentLocation.machines.count];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Location *currentLocation;
    if (tableView == self.tableView){
        currentLocation = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentLocation = [searchResults objectAtIndex:indexPath.row];
        [self.searchDisplayController.searchBar resignFirstResponder];
    }
    if (_isSelecting){
        if ([_selectingViewController respondsToSelector:@selector(setLocation:)]){
            [_selectingViewController setLocation:currentLocation];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    if ([UIDevice iPad]){
        LocationProfileView_iPad *profileView = (LocationProfileView_iPad *)self.parentViewController;
        [profileView setCurrentLocation:currentLocation];
    }else{
        LocationProfileView *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationProfileView"];
        profile.currentLocation = currentLocation;
        [self.navigationController pushViewController:profile animated:YES];
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
