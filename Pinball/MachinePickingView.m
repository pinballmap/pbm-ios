//
//  MachinePickingView.m
//  PinballMap
//
//  Created by Frank Michael on 4/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachinePickingView.h"

@interface MachinePickingView () <NSFetchedResultsControllerDelegate,UISearchBarDelegate,UIAlertViewDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResults;
@property (nonatomic) NSManagedObjectContext *managedContext;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL onlyPicked;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) NSMutableArray *pickedMachines;

@property (weak) IBOutlet UISegmentedControl *machineFilter;
@property (weak) IBOutlet UISearchBar *mainSearchbar;


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
    
    self.managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    if (!self.pickedMachines){
        self.pickedMachines = [NSMutableArray new];
    }
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
    stackRequest.predicate = nil;
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:stackRequest
                                                         managedObjectContext:self.managedContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    self.fetchedResults.delegate = self;
    [self.fetchedResults performFetch:nil];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class
- (void)setExistingPickedMachines:(NSArray *)existingPickedMachines{
    _existingPickedMachines = existingPickedMachines;
    if (!_pickedMachines){
        _pickedMachines = [NSMutableArray new];
    }
    [_pickedMachines addObjectsFromArray:_existingPickedMachines];
}
#pragma mark - Class Actions
- (IBAction)savePicked:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(pickedMachines:)]){
        [_delegate pickedMachines:self.pickedMachines];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelPicking:(id)sender{
    [_delegate pickedMachines:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)filterMachines:(id)sender{
    self.isSearching = NO;
    [self.mainSearchbar resignFirstResponder];
    self.mainSearchbar.text = @"";
    if (self.machineFilter.selectedSegmentIndex == 0){
        self.onlyPicked = NO;
    }else if (self.machineFilter.selectedSegmentIndex == 1){
        self.onlyPicked = YES;
    }else{
        // New Machine is trying to be added
        UIAlertView *newMachineNameAlert = [[UIAlertView alloc] initWithTitle:@"New Machine" message:@"Enter the machine name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        newMachineNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[newMachineNameAlert textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [newMachineNameAlert show];
        self.machineFilter.selectedSegmentIndex = 0;
    }
    [self.tableView reloadData];
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex){
        // Create newly typed in machine
        NSString *machineName = [[alertView textFieldAtIndex:0] text];
        
    
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (self.isSearching){
        rows = self.searchResults.count;
    }else if (self.onlyPicked){
        rows = self.pickedMachines.count;
    }else{
        if ([[self.fetchedResults sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float defaultWidth = 290;
    
    Machine *currentMachine;
    if (self.isSearching){
        currentMachine = self.searchResults[indexPath.row];
    }else if (self.onlyPicked){
        currentMachine = self.pickedMachines[indexPath.row];
    }else{
        currentMachine = [self.fetchedResults objectAtIndexPath:indexPath];
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
    if (self.isSearching){
        currentMachine = self.searchResults[indexPath.row];
    }else if (self.onlyPicked){
        currentMachine = self.pickedMachines[indexPath.row];
    }else{
        currentMachine = [self.fetchedResults objectAtIndexPath:indexPath];
    }
    
    if ([self.pickedMachines containsObject:currentMachine]){
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
    if (self.isSearching){
        currentMachine = self.searchResults[indexPath.row];
    }else if (self.onlyPicked){
        currentMachine = self.pickedMachines[indexPath.row];
    }else{
        currentMachine = [self.fetchedResults objectAtIndexPath:indexPath];
    }
    if ([self.pickedMachines containsObject:currentMachine]){
        [self.pickedMachines removeObject:currentMachine];
    }else{
        [self.pickedMachines addObject:currentMachine];
    }
    if (!_canPickMultiple){
        [self savePicked:nil];
    }else{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
@end
