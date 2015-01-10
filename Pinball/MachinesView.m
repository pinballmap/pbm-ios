//
//  MachinesView.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachinesView.h"
#import "MachineLocation.h"
#import "MachineProfileView.h"
#import "GAAppHelper.h"
#import "MachineManufacturerView.h"
#import "UIViewController+Helpers.h"

@interface MachinesView () <NSFetchedResultsControllerDelegate,UISearchBarDelegate,UIActionSheetDelegate,ManufacturerSelectionDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResults;
@property (nonatomic) NSManagedObjectContext *managedContext;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) NSMutableArray *searchResults;

- (IBAction)addMachine:(id)sender;
- (IBAction)sortOptions:(id)sender;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRegion) name:@"RegionUpdate" object:nil];
    
    UIBarButtonItem *sort = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(sortOptions:)];
    self.navigationItem.leftBarButtonItem = sort;
    
    [self updateRegion];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [GAAppHelper sendAnalyticsDataWithScreen:@"Machines View"];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ProfileView"]){
        Machine *currentMachine;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (!self.isSearching){
            currentMachine = [self.fetchedResults objectAtIndexPath:indexPath];
        }else{
            currentMachine = self.searchResults[indexPath.row];
        }
        MachineProfileView *profileView = segue.destinationViewController;
        profileView.currentMachine = currentMachine;
    }
}
#pragma mark - Class Actions
- (IBAction)addMachine:(id)sender{
    UINavigationController *newMachine = [self.storyboard instantiateViewControllerWithIdentifier:@"NewMachineView"];
    if ([UIDevice iPad]){
        newMachine.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self.navigationController presentViewController:newMachine animated:YES completion:nil];
}
- (IBAction)sortOptions:(id)sender{
    UIActionSheet *sortOptions = [[UIActionSheet alloc] initWithTitle:@"Machine Sort" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Manufacture", nil];
    [sortOptions showInView:self.view];
}
#pragma mark - Region Update
- (void)updateRegion{
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Machines",[[[PinballMapManager sharedInstance] currentRegion] fullName]];
    self.managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
    stackRequest.predicate = [NSPredicate predicateWithFormat:@"machineLocations.location.region CONTAINS %@" argumentArray:@[[[PinballMapManager sharedInstance] currentRegion]]];
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                         managedObjectContext:self.managedContext
                                                           sectionNameKeyPath:@"name"
                                                                    cacheName:nil];
    self.fetchedResults.delegate = self;
    [self.fetchedResults performFetch:nil];
    [self.tableView reloadData];
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        if (buttonIndex == 0){
            // Manufacture Sort
            MachineManufacturerView *manView = (MachineManufacturerView*)[[self.storyboard instantiateViewControllerWithIdentifier:@"MachineManufacturerView"] navigationRootViewController];
            manView.delegate = self;
            [self presentViewController:manView.parentViewController animated:true completion:nil];
        }
    }
}
#pragma mark - Manufacturer Delegate
- (void)selectedManufacturer:(NSString *)manufacturer{
    if (manufacturer.length > 0){
        self.managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
        NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
        stackRequest.predicate = [NSPredicate predicateWithFormat:@"machineLocations.location.region CONTAINS %@ AND manufacturer = %@" argumentArray:@[[[PinballMapManager sharedInstance] currentRegion],manufacturer]];
        stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                                  managedObjectContext:self.managedContext
                                                                    sectionNameKeyPath:@"name"
                                                                             cacheName:nil];
        self.fetchedResults.delegate = self;
        [self.fetchedResults performFetch:nil];
        [self.tableView reloadData];
    }
}
#pragma mark - Searchbar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.isSearching = YES;
    searchBar.showsCancelButton = YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSFetchRequest *searchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
    searchrequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",searchText];
    [self.searchResults removeAllObjects];
    self.searchResults = nil;
    self.searchResults = [NSMutableArray new];
    NSError *error = nil;
    [self.searchResults addObjectsFromArray:[self.managedContext executeFetchRequest:searchrequest error:&error]];
    [self.tableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.isSearching = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!self.isSearching){
        return [[self.fetchedResults sections] count];
    }else{
        return 1;
    }
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (!self.isSearching){
        return [self.fetchedResults sectionIndexTitles];
    }
    return @[];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [self.fetchedResults sectionForSectionIndexTitle:title atIndex:index];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (!self.isSearching){
        if ([[self.fetchedResults sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }
    }else{
        rows = self.searchResults.count;
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float defaultWidth = 255;
    
    Machine *currentMachine;
    if (!self.isSearching){
        currentMachine = [self.fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentMachine = self.searchResults[indexPath.row];
    }
    
    NSString *detailString = [NSString stringWithFormat:@"%@, %@",currentMachine.manufacturer,currentMachine.year];
    
    CGRect titleLabel = [currentMachine.name boundingRectWithSize:CGSizeMake(defaultWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]} context:nil];//boundingRectWithSize:CGSizeMake(defaultWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGRect detailLabel = [detailString boundingRectWithSize:CGSizeMake(defaultWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
    // Add 6 pixel padding present in subtitle style.
    CGRect stringSize = CGRectMake(0, 0, defaultWidth, titleLabel.size.height+detailLabel.size.height+6);
    return stringSize.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    Machine *currentMachine;
    if (!self.isSearching){
        currentMachine = [self.fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentMachine = self.searchResults[indexPath.row];
    }

    cell.textLabel.text = currentMachine.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",currentMachine.manufacturer,currentMachine.year];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Machine *currentMachine;
    if (!self.isSearching){
        currentMachine = [self.fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentMachine = self.searchResults[indexPath.row];
    }
    if ([UIDevice iPad]){
        MachineProfileView *profileView = (MachineProfileView *)[[self.splitViewController detailViewForSplitView] navigationRootViewController];
        [profileView setCurrentMachine:currentMachine];
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
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
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
