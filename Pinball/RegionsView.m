//
//  RegionsView.m
//  Pinball
//
//  Created by Frank Michael on 4/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "RegionsView.h"
@import MessageUI;
#import "UIAlertView+Application.h"

@interface RegionsView () <UISearchBarDelegate,MFMailComposeViewControllerDelegate> {
    NSMutableArray *allRegions;
    BOOL isSearching;
    NSMutableArray *searchResults;
}
- (IBAction)cancelRegion:(id)sender;    // iPad only.
- (IBAction)requestRegion:(id)sender;

@end

@implementation RegionsView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Regions";
    allRegions = [NSMutableArray new];
    [[PinballManager sharedInstance] allRegions:^(NSArray *regions) {
        [allRegions removeAllObjects];
        [allRegions addObjectsFromArray:regions];
        [self.tableView reloadData];
    }];
    searchResults = [NSMutableArray new];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class actions
- (IBAction)requestRegion:(id)sender{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *requestMessage = [[MFMailComposeViewController alloc] init];
        requestMessage.mailComposeDelegate = self;
        [requestMessage setSubject:@"Adding my region to PinballMap.com"];
        [requestMessage setToRecipients:@[@"gratzer@gmail.com"]];
        [self presentViewController:requestMessage animated:YES completion:nil];
    }
}
- (IBAction)cancelRegion:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - MFMailComposeDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result == MFMailComposeResultFailed){
        [UIAlertView simpleApplicationAlertWithMessage:@"Message failed to send." cancelButton:@"Ok"];
    }else if (result == MFMailComposeResultSent){
        [UIAlertView simpleApplicationAlertWithMessage:@"Message sent. Thank You!" cancelButton:@"Ok"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Searchbar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    isSearching = YES;
    searchBar.showsCancelButton = YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSPredicate *searchPred = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@",searchText];
    [searchResults removeAllObjects];
    searchResults = nil;
    searchResults = [NSMutableArray new];
    [searchResults addObjectsFromArray:[allRegions filteredArrayUsingPredicate:searchPred]];
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
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!isSearching){
        return allRegions.count;
    }else{
        return searchResults.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegionCell" forIndexPath:indexPath];
    
    Region *region;
    if (!isSearching){
        region = allRegions[indexPath.row];
    }else{
        region = searchResults[indexPath.row];
    }
    cell.textLabel.text = region.fullName;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Region *region;
    if (!isSearching){
        region = allRegions[indexPath.row];
    }else{
        region = searchResults[indexPath.row];
    }
    [[PinballManager sharedInstance] loadRegionData:region];
    if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
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
