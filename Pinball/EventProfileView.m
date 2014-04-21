//
//  EventProfileView.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "EventProfileView.h"
#import "InformationCell.h"
#import "NSDate+DateFormatting.h"
#import "LocationProfileView.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "UIAlertView+Application.h"
@interface EventProfileView () <EKEventViewDelegate>{
    
}

@end

@implementation EventProfileView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = _currentEvent.name;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];

    if (indexPath.row == 0){
        cell.infoLabel.text = @"Description";
        cell.dataLabel.text = _currentEvent.eventDescription;
    }else if (indexPath.row == 1){
        cell.infoLabel.text = @"Link";
        cell.dataLabel.text = _currentEvent.link;
    }else if (indexPath.row == 2){
        cell.infoLabel.text = @"Date";
        cell.dataLabel.text = [_currentEvent.startDate monthDayYearPretty:YES];
    }else if (indexPath.row == 3){
        cell.infoLabel.text = @"Location";
        cell.dataLabel.text = _currentEvent.location.name;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1){
        if (_currentEvent.link.length > 0 && ![_currentEvent.link isEqualToString:@"N/A"]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_currentEvent.link]];
        }
    }else if (indexPath.row == 2){
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted){
                    EKEvent *newEvent = [EKEvent eventWithEventStore:store];
                    newEvent.startDate = _currentEvent.startDate;
                    newEvent.endDate = _currentEvent.startDate;
                    newEvent.location = _currentEvent.location.name;
                    newEvent.title = _currentEvent.name;
                    newEvent.allDay = YES;
                    newEvent.URL = [NSURL URLWithString:_currentEvent.link];
                    
                    EKEventViewController *eventView = [[EKEventViewController alloc] init];
                    eventView.event = newEvent;
                    eventView.allowsEditing = YES;
                    eventView.delegate = self;
                    UINavigationController *eventNav = [[UINavigationController alloc] initWithRootViewController:eventView];
                    [self.navigationController presentViewController:eventNav animated:YES completion:nil];
                }else{
                    [UIAlertView simpleApplicationAlertWithMessage:@"You must grant access to your calender to save this event." cancelButton:@"Ok"];
                }
            });
        }];
    }else if (indexPath.row == 3){
        LocationProfileView *locationProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationProfileView"];
        locationProfile.currentLocation = _currentEvent.location;
        [self.navigationController pushViewController:locationProfile animated:YES];
    }
}
#pragma mark - EventView Delegate
- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action{
    if (action == EKEventViewActionDone || action == EKEventViewActionResponded){
        [UIAlertView simpleApplicationAlertWithMessage:@"Added Event!" cancelButton:@"Ok"];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
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
