//
//  ZonesView.m
//  PinballMap
//
//  Created by Frank Michael on 6/16/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "ZonesView.h"
#import "Region.h"

@interface ZonesView () <NSFetchedResultsControllerDelegate,UISearchDisplayDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResults;
@property (nonatomic) NSMutableArray *searchResults;

- (IBAction)dismissZones:(id)sender;

@end

@implementation ZonesView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchResults = [NSMutableArray new];
    Region *currentRegion = [[PinballMapManager sharedInstance] currentRegion];
    
    self.navigationItem.title = currentRegion.fullName;
    
    NSFetchRequest *zoneFetch = [NSFetchRequest fetchRequestWithEntityName:@"Zone"];
    zoneFetch.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND self.locations.@count > 0",currentRegion.name];
    zoneFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:zoneFetch
                                                         managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]
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
#pragma mark - Class Actions
- (IBAction)dismissZones:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSFetchRequest *searchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Zone"];
    searchrequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ AND region.name = %@",searchString,[[[PinballMapManager sharedInstance] currentRegion] name]];

    [self.searchResults removeAllObjects];
    self.searchResults = nil;
    self.searchResults = [NSMutableArray new];
    NSError *error = nil;
    [self.searchResults addObjectsFromArray:[[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:searchrequest error:&error]];
    
    return YES;
}
#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.tableView){
        return [[self.fetchedResults sections] count];
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (tableView == self.tableView){
        if ([[self.fetchedResults sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }
    }else{
        rows = self.searchResults.count;
    }
    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ZoneCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [(UITableViewCell *)[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Zone *currentZone;
    if (tableView == self.tableView){
        currentZone = [self.fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentZone = [self.searchResults objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = currentZone.name;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Zone *currentZone;
    if (tableView == self.tableView){
        currentZone = [self.fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentZone = [self.searchResults objectAtIndex:indexPath.row];
    }

    if (_delegate && [_delegate respondsToSelector:@selector(selectedZone:)]){
        [_delegate selectedZone:currentZone];
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
