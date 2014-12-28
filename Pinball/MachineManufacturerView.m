//
//  MachineManufacturerView.m
//  PinballMap
//
//  Created by Frank Michael on 12/28/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineManufacturerView.h"

@interface MachineManufacturerView ()

@property (nonatomic) NSFetchedResultsController *fetchedResults;

@end

@implementation MachineManufacturerView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Navigation
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSelection:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    NSEntityDescription *machineEntity = [NSEntityDescription entityForName:@"Machine" inManagedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]];
    // Setup count computed attribute
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"manufacturer"];
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:@[keyPathExpression]];
    NSExpressionDescription *countDescription = [[NSExpressionDescription alloc] init];
    countDescription.name = @"count";
    countDescription.expression = countExpression;
    countDescription.expressionResultType = NSInteger32AttributeType;
    
    
    NSFetchRequest *machineManFetch = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
    machineManFetch.predicate = [NSPredicate predicateWithFormat:@"machineLocations.location.region CONTAINS %@" argumentArray:@[[[PinballMapManager sharedInstance] currentRegion]]];
    machineManFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"manufacturer" ascending:true]];
    machineManFetch.propertiesToGroupBy = @[[machineEntity.attributesByName objectForKey:@"manufacturer"]];
    machineManFetch.propertiesToFetch = @[[machineEntity.attributesByName objectForKey:@"manufacturer"],countDescription];
    machineManFetch.resultType = NSDictionaryResultType;
    
    self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:machineManFetch
                                                              managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]
                                                                sectionNameKeyPath:nil
                                                                         cacheName:nil];
    [self.fetchedResults performFetch:nil];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class Actions
- (IBAction)dismissSelection:(id)sender{
    [self dismissViewControllerAnimated:true completion:nil];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResults sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
        NSInteger rows = [sectionInfo numberOfObjects];
        return rows;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineManCell"];

    NSDictionary *manDic = [self.fetchedResults objectAtIndexPath:indexPath];
    NSString *manName = manDic[@"manufacturer"];
    if (manName.length == 0){
        manName = @"Unknown";
    }
    cell.textLabel.text = manName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of Machines: %i",(int)manDic[@"count"]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary *manDic = [self.fetchedResults objectAtIndexPath:indexPath];

}

@end
