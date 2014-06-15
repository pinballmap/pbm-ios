//
//  LocationTypesView.m
//  PinballMap
//
//  Created by Frank Michael on 5/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationTypesView.h"

@interface LocationTypesView () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *locationTypesFetch;
}
- (IBAction)dismissTypes:(id)sender;

@end

@implementation LocationTypesView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSFetchRequest *typeFetch = [NSFetchRequest fetchRequestWithEntityName:@"LocationType"];
    typeFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    locationTypesFetch = [[NSFetchedResultsController alloc] initWithFetchRequest:typeFetch
                                                             managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]
                                                               sectionNameKeyPath:nil
                                                                        cacheName:nil];
    locationTypesFetch.delegate = self;
    [locationTypesFetch performFetch:nil];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class Actions
- (IBAction)dismissTypes:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(pickedType:)]){
        [_delegate pickedType:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if ([[locationTypesFetch sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[locationTypesFetch sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }

    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationTypeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    LocationType *type = [locationTypesFetch objectAtIndexPath:indexPath];
    cell.textLabel.text = type.name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LocationType *type = [locationTypesFetch objectAtIndexPath:indexPath];
    if (_delegate && [_delegate respondsToSelector:@selector(pickedType:)]){
        [_delegate pickedType:type];
        [self dismissViewControllerAnimated:YES completion:nil];
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
