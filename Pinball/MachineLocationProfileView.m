//
//  MachineLocationProfileView.m
//  Pinball
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocationProfileView.h"
#import "MachineConditionView.h"
#import "UIAlertView+Application.h"
#import "MachineScore.h"
#import "NewMachineScoreView.h"

@interface MachineLocationProfileView () <ScoreDelegate> {
    NSMutableArray *machineScores;
    UIAlertView *deleteConfirm;
    NSIndexPath *deletePath;
}


- (IBAction)dismissProfile:(id)sender;
@end

@implementation MachineLocationProfileView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    machineScores = [NSMutableArray new];
    [self reloadScores];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class
- (void)reloadScores{
    if (!machineScores){
        machineScores = [NSMutableArray new];
    }
    [machineScores removeAllObjects];
    [[PinballManager sharedInstance] allScoresForMachine:_currentMachine withCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            [status[@"machine_scores"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MachineScore *score = [[MachineScore alloc] initWithData:obj];
                [machineScores addObject:score];
            }];
            [self.tableView reloadData];
        }
    }];
}
#pragma mark - Class Actions
- (IBAction)dismissProfile:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Score Delegate
- (void)didAddScore{
    [self reloadScores];
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex){
        if (alertView == deleteConfirm){
            MachineLocation *machine = _currentMachine;//[machinesFetch objectAtIndexPath:[NSIndexPath indexPathForItem:deletePath.row inSection:0]];
            [[PinballManager sharedInstance] removeMachine:machine withCompletion:^(NSDictionary *status) {
                if (status[@"errors"]){
                    NSString *errors;
                    if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                        errors = [status[@"errors"] componentsJoinedByString:@","];
                    }else{
                        errors = status[@"errors"];
                    }
                    [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
                }else{
                    [[[CoreDataManager sharedInstance] managedObjectContext] deleteObject:machine];
                    [[CoreDataManager sharedInstance] saveContext];
                    deletePath = nil;
                    [UIAlertView simpleApplicationAlertWithMessage:@"Removed machine!" cancelButton:@"Ok"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }else if (section == 1){
        return machineScores.count+1;
    }else{
        return 1;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Machine Condition (tap to edit)";
    }else if (section == 1){
        return @"Scores";
    }else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1 || indexPath.section == 2){
        return 44;
    }
    CGRect conditionHeight = [_currentMachine.condition boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
    if (conditionHeight.size.height+10 < 44){
        return 44;
    }else{
        return conditionHeight.size.height+10;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.section == 0 || indexPath.section == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    }else{
        if (indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell"];
        }
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    if (indexPath.section == 0){
        cell.textLabel.text = _currentMachine.condition;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0){
            cell.textLabel.text = @"Add your score";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }else{
            MachineScore *score = machineScores[indexPath.row-1];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",score.score,score.initials];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[MachineScore wordingForRank:score.rank]];
        }
    }else if (indexPath.section == 2){
        cell.textLabel.text = @"Remove Machine";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        MachineConditionView *vc = (MachineConditionView *)[[[self.storyboard instantiateViewControllerWithIdentifier:@"MachineCondition"] viewControllers] lastObject];
        vc.currentMachine = _currentMachine;
        [tableView setEditing:NO];
        [self.navigationController presentViewController:vc.parentViewController animated:YES completion:nil];
    }else if (indexPath.section == 1 && indexPath.row == 0){
        NewMachineScoreView *scoreView = [[[self.storyboard instantiateViewControllerWithIdentifier:@"NewMachineScoreView"] viewControllers] lastObject];
        scoreView.currentMachine = _currentMachine;
        scoreView.delegate = self;
        [self.navigationController presentViewController:scoreView.parentViewController animated:YES completion:nil];
    }else if (indexPath.section == 2){
        deletePath = indexPath;
        deleteConfirm = [UIAlertView applicationAlertWithMessage:@"Are you sure you want to remove this machine." delegate:self cancelButton:@"No" otherButtons:@"Yes", nil];
        [deleteConfirm show];
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
