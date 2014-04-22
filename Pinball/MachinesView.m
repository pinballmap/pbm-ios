//
//  MachinesView.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachinesView.h"
#import "MachineLocation.h"
#import "MachineProfileView.h"
@interface MachinesView () <NSFetchedResultsControllerDelegate,UISearchBarDelegate>{
    NSFetchedResultsController *fetchedResults;
    NSManagedObjectContext *managedContext;
    BOOL isSearching;
    NSMutableArray *searchResults;
}

@end

@implementation MachinesView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Machines",[[[PinballManager sharedInstance] currentRegion] fullName]];
    
    managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
    stackRequest.predicate = nil;
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ProfileView"]){
        Machine *currentMachine;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (!isSearching){
            currentMachine = [fetchedResults objectAtIndexPath:indexPath];
        }else{
            currentMachine = searchResults[indexPath.row];
        }
        MachineProfileView *profileView = segue.destinationViewController;
        profileView.currentMachine = currentMachine;
    }
}
#pragma mark - Searchbar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    isSearching = YES;
    searchBar.showsCancelButton = YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSFetchRequest *searchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
    searchrequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",searchText];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float defaultWidth = 270;
    
    Machine *currentMachine;
    if (!isSearching){
        currentMachine = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentMachine = searchResults[indexPath.row];
    }
    NSString *mainString = currentMachine.name;
    NSString *detailString = [NSString stringWithFormat:@"Locations: %lu",(unsigned long)currentMachine.machineLocations.count];

    CGRect textLabel = [mainString boundingRectWithSize:CGSizeMake(defaultWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
    CGRect detailLabel = [detailString boundingRectWithSize:CGSizeMake(defaultWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
    // Add 6 pixel padding present in subtitle style.
    CGRect stringSize = CGRectMake(0, 0, defaultWidth, textLabel.size.height+detailLabel.size.height+6);
    return stringSize.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    Machine *currentMachine;
    if (!isSearching){
        currentMachine = [fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentMachine = searchResults[indexPath.row];
    }
    cell.textLabel.text = currentMachine.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Locations: %lu",(unsigned long)currentMachine.machineLocations.count];
    return cell;
}

@end
