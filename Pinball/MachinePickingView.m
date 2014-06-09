//
//  MachinePickingView.m
//  Pinball
//
//  Created by Frank Michael on 4/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachinePickingView.h"

@interface MachinePickingView () <NSFetchedResultsControllerDelegate,UISearchBarDelegate> {
    IBOutlet UISegmentedControl *machineFilter;
    IBOutlet UISearchBar *mainSearchbar;
    NSFetchedResultsController *fetchedResults;
    NSManagedObjectContext *managedContext;
    BOOL isSearching;
    BOOL onlyPicked;
    NSMutableArray *searchResults;
    NSMutableArray *pickedMachines;
}
- (IBAction)filterMachines:(id)sender;
- (IBAction)savePicked:(id)sender;
- (IBAction)cancelPicking:(id)sender;
@end

@implementation MachinePickingView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    if (!pickedMachines){
        pickedMachines = [NSMutableArray new];
    }
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
#pragma mark - Class
- (void)setPickedMachines:(NSArray *)pickedMachinesInput{
    _existingPickedMachines = pickedMachinesInput;
    if (!pickedMachines){
        pickedMachines = [NSMutableArray new];
    }
    [pickedMachines addObjectsFromArray:_existingPickedMachines];
}
#pragma mark - Class Actions
- (IBAction)savePicked:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(pickedMachines:)]){
        [_delegate pickedMachines:pickedMachines];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelPicking:(id)sender{
    [_delegate pickedMachines:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)filterMachines:(id)sender{
    isSearching = NO;
    [mainSearchbar resignFirstResponder];
    mainSearchbar.text = @"";
    if (machineFilter.selectedSegmentIndex == 0){
        onlyPicked = NO;
    }else{
        onlyPicked = YES;
    }
    [self.tableView reloadData];
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
    if (isSearching){
        rows = searchResults.count;
    }else if (onlyPicked){
        rows = pickedMachines.count;
    }else{
        if ([[fetchedResults sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResults sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float defaultWidth = 290;
    
    Machine *currentMachine;
    if (isSearching){
        currentMachine = searchResults[indexPath.row];
    }else if (onlyPicked){
        currentMachine = pickedMachines[indexPath.row];
    }else{
        currentMachine = [fetchedResults objectAtIndexPath:indexPath];
    }
    
    CGRect stringSize = [currentMachine.machineTitle boundingRectWithSize:CGSizeMake(defaultWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (stringSize.size.height <= 44){
        return 44;
    }
    return stringSize.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    Machine *currentMachine;
    if (isSearching){
        currentMachine = searchResults[indexPath.row];
    }else if (onlyPicked){
        currentMachine = pickedMachines[indexPath.row];
    }else{
        currentMachine = [fetchedResults objectAtIndexPath:indexPath];
    }
    
    if ([pickedMachines containsObject:currentMachine]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.attributedText = currentMachine.machineTitle;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Machine *currentMachine;
    if (isSearching){
        currentMachine = searchResults[indexPath.row];
    }else if (onlyPicked){
        currentMachine = pickedMachines[indexPath.row];
    }else{
        currentMachine = [fetchedResults objectAtIndexPath:indexPath];
    }
    if ([pickedMachines containsObject:currentMachine]){
        [pickedMachines removeObject:currentMachine];
    }else{
        [pickedMachines addObject:currentMachine];
    }
    if (!_canPickMultiple){
        [self savePicked:nil];
    }else{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
@end
