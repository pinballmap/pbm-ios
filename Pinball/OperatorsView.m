#import "OperatorsView.h"
#import "Region.h"

@interface OperatorsView () <NSFetchedResultsControllerDelegate,UISearchDisplayDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResults;
@property (nonatomic) NSMutableArray *searchResults;

- (IBAction)dismissOperators:(id)sender;

@end

@implementation OperatorsView

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
    
    NSFetchRequest *operatorFetch = [NSFetchRequest fetchRequestWithEntityName:@"Operator"];
    operatorFetch.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND self.locations.@count > 0",currentRegion.name];
    operatorFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:operatorFetch
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
- (IBAction)dismissOperators:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSFetchRequest *searchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Operator"];
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
    static NSString *cellIdentifier = @"OperatorCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [(UITableViewCell *)[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Operator *currentOperator;
    if (tableView == self.tableView){
        currentOperator = [self.fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentOperator = [self.searchResults objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = currentOperator.name;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Operator *currentOperator;
    if (tableView == self.tableView){
        currentOperator = [self.fetchedResults objectAtIndexPath:indexPath];
    }else{
        currentOperator = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectedOperator:)]){
        [_delegate selectedOperator:currentOperator];
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
