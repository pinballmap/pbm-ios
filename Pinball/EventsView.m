//
//  EventsView.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "EventsView.h"
#import "NSDate+DateFormatting.h"
#import "EventProfileView.h"

@interface EventsView () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResults;
    NSManagedObjectContext *managedContext;
}

@end

@implementation EventsView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Events",[[[PinballManager sharedInstance] currentRegion] fullName]];
    managedContext = [[CoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    stackRequest.predicate = nil;
    stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
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
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[fetchedResults sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if ([[fetchedResults sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResults sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *currentEvent = [fetchedResults objectAtIndexPath:indexPath];
    NSString *cellTitle = currentEvent.name;

    CGRect stringSize = [cellTitle boundingRectWithSize:CGSizeMake(270, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];

    stringSize.size.height = stringSize.size.height+10;   // Take into account the 10 points of padding within a cell.
    if (stringSize.size.height+10 < 44){
        return 44;
    }else{
        return stringSize.size.height+10;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    Event *currentEvent = [fetchedResults objectAtIndexPath:indexPath];
    cell.textLabel.text = currentEvent.name;
    cell.detailTextLabel.text = [currentEvent.startDate monthDayYearPretty:YES];
    
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"EventProfileView"]){
        Event *currentEvent = [fetchedResults objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        EventProfileView *profile = segue.destinationViewController;
        profile.currentEvent = currentEvent;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
