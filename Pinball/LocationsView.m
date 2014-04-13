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

@interface LocationsView () <NSFetchedResultsControllerDelegate,UIActionSheetDelegate,UISearchBarDelegate> {
    NSFetchedResultsController *fetchedResults;
    NSManagedObjectContext *managedContext;
    BOOL isSearching;
    NSMutableArray *searchResults;
}
- (IBAction)filterResults:(id)sender;

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
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Locations",[[[PinballManager sharedInstance] currentRegion] fullName]];
    managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    stackRequest.predicate = nil;
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"machineCount" ascending:NO]];
    fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                         managedObjectContext:managedContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    fetchedResults.delegate = self;
    [fetchedResults performFetch:nil];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Searchbar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    isSearching = YES;
    searchBar.showsCancelButton = YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSFetchRequest *searchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    searchrequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",searchText];
    [searchResults removeAllObjects];
    searchResults = nil;
    searchResults = [NSMutableArray new];
    NSError *error = nil;
    [searchResults addObjectsFromArray:[managedContext executeFetchRequest:searchrequest error:&error]];
    NSLog(@"%@",error);
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Location Filter" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Location (Closets)",@"Number of Machines",@"Name", nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
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
        if (buttonIndex == 0){
            // Location
        }else if (buttonIndex == 1){
            // Number
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"machineCount" ascending:NO]];
        }else if (buttonIndex == 2){
            // Name
            stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        }
        
        fetchedResults = nil;
        fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                             managedObjectContext:managedContext
                                                               sectionNameKeyPath:nil
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    
    Location *currentLocation;
    if (!isSearching){
        currentLocation = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentLocation = [searchResults objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = currentLocation.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Machines: %lu",(unsigned long)currentLocation.machines.count];
    return cell;
}

@end
