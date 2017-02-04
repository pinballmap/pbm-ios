//
//  MachineLocationProfileView.m
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocationProfileView.h"
#import "MachineConditionView.h"
#import "UIAlertView+Application.h"
#import "MachineScore.h"
#import "NewMachineScoreView.h"
#import "MachineCondition.h"
#import "TextEditorView.h"
#import "NSDate+DateFormatting.h"
#import "MachineCondition+Create.h"

@interface MachineLocationProfileView () <ScoreDelegate,TextEditorDelegate>

@property (nonatomic) NSMutableArray *machineScores;
@property (nonatomic) NSMutableArray *machineConditionsArray;
@property (nonatomic) UIAlertView *deleteConfirm;
@property (nonatomic) NSIndexPath *deletePath;


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
    self.machineScores = [NSMutableArray new];
    self.navigationItem.title = _currentMachine.machine.name;
    
    [self reloadMachineConditionArray];
    [self reloadScores];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)reloadMachineConditionArray{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conditionId" ascending:NO];
    NSArray *sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [_currentMachine.conditions.allObjects sortedArrayUsingDescriptors:sortDescriptors];
    
    self.machineConditionsArray = [NSMutableArray arrayWithArray:sortedArray];
    
    if ([self.machineConditionsArray count] > 0) {
        [self.machineConditionsArray removeObjectAtIndex:0]; //get rid of the "current" condition
    }
    
    NSLog(@"%@",self.machineConditionsArray);
}

#pragma mark - Class
- (void)reloadPastConditions{
    if (!self.machineConditionsArray){
        self.machineConditionsArray = [NSMutableArray new];
    }
    [self.machineConditionsArray removeAllObjects];
    
    [[PinballMapManager sharedInstance] machineLocationInfo:_currentMachine withCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            NSManagedObjectContext *context = [[CoreDataManager sharedInstance] managedObjectContext];

            for (MachineCondition *condition in self.currentMachine.conditions) {
                [context deleteObject:condition];
            }
            
            NSArray *conditions = status[@"location_machine"][@"machine_conditions"];
            if (conditions.count > 0){
                for (NSDictionary *condition in conditions) {
                    MachineCondition *machineCondition = [MachineCondition createMachineConditionWithData:condition andContext:context];
                    if (machineCondition != nil){
                        machineCondition.machineLocation = self.currentMachine;
                        [self.currentMachine addConditionsObject:machineCondition];
                        [self.machineConditionsArray addObject:machineCondition];
                    }
                }
            }
            
            [[CoreDataManager sharedInstance] saveContext];
            [self reloadMachineConditionArray];
            [self.tableView reloadData];
        }
    }];
}
- (void)reloadScores{
    if (!self.machineScores){
        self.machineScores = [NSMutableArray new];
    }
    [self.machineScores removeAllObjects];
    
    [[PinballMapManager sharedInstance] allScoresForMachine:_currentMachine withCompletion:^(NSDictionary *status) {
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
                [self.machineScores addObject:score];
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
        if (alertView == self.deleteConfirm){
            MachineLocation *machine = _currentMachine;
            [[PinballMapManager sharedInstance] removeMachine:machine withCompletion:^(NSDictionary *status) {
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
                    
                    machine.location.lastUpdatedByUsername = [[PinballMapManager sharedInstance] currentUser].username;
                    machine.location.lastUpdated = [NSDate date];
                    
                    [[CoreDataManager sharedInstance] saveContext];
                    self.deletePath = nil;
                    [UIAlertView simpleApplicationAlertWithMessage:@"Removed machine!" cancelButton:@"Ok"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"removedMachine" object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1){
        return 1;
    }else if (section == 2){
        return self.machineConditionsArray.count;
    }else if (section == 3){
        return self.machineScores.count+1;
    }else{
        return 1;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Location";
    }else if (section == 1){
        return @"Machine Condition (tap to add new)";
    }else if (section == 2 && self.machineConditionsArray.count > 0){
        return @"Past Conditions";
    }else if (section == 3){
        return @"Scores";
    }else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 3 || indexPath.section == 4){
        return 44;
    }
    
    NSString *cellText;
    if (indexPath.section == 0){
        cellText = _currentMachine.location.name;
    }else if (indexPath.section == 1){
        BOOL addBy = ([_currentMachine.updatedByUsername isKindOfClass:[NSNull class]] || [_currentMachine.updatedByUsername length] == 0) ? NO : YES;

        cellText = [_currentMachine formattedConditionDate:addBy conditionUpdate:_currentMachine.conditionUpdate];
    }else if (indexPath.section == 2){
        MachineCondition *condition = self.machineConditionsArray[indexPath.row];
        cellText = condition.comment;
    }
    
    CGRect conditionHeight = [cellText boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
    if (conditionHeight.size.height+10 < 44){
        return 44;
    }else{
        return conditionHeight.size.height+10;
    }
}
- (UITableViewCell *)formatConditionCell:(UITableViewCell *)cell machineCondition:(MachineCondition *)oldMachineCondition {
    cell.textLabel.text = nil;
    
    NSString *condition = oldMachineCondition ? oldMachineCondition.comment : _currentMachine.condition;
    
    UILabel *conditionLabel = (UILabel *)[cell viewWithTag:100];
    conditionLabel.text = condition;
    [conditionLabel sizeToFit];
    
    NSString *username = oldMachineCondition ? oldMachineCondition.createdByUsername : _currentMachine.updatedByUsername;
    NSDate *conditionDate = oldMachineCondition ? oldMachineCondition.conditionCreated : _currentMachine.conditionUpdate;
    BOOL addBy = ([username isKindOfClass:[NSNull class]] || [username length] == 0) ? NO : YES;
    NSString *conditionDateString = oldMachineCondition ? [_currentMachine pastConditionWithUpdateDate:oldMachineCondition] :[_currentMachine formattedConditionDate:addBy conditionUpdate:conditionDate];
    UILabel *conditionDateLabel = (UILabel *)[cell viewWithTag:101];
    conditionDateLabel.text = conditionDateString;
    [conditionDateLabel sizeToFit];
    
    if (addBy) {
        UILabel *usernameLabel = (UILabel *)[cell viewWithTag:102];
        usernameLabel.text = username;
        [usernameLabel sizeToFit];
        
        CGRect conditionFrame = conditionDateLabel.frame;
        CGRect frame = usernameLabel.frame;
        frame.origin.x = conditionFrame.size.width + 10;
        usernameLabel.frame = frame;
    }
    
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    }else if (indexPath.section == 1 || indexPath.section == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ConditionCell"];
    }else if (indexPath.section == 3){
        if (indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell"];
        }
    }else{
        if (indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell"];
        }
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blackColor];
    if (indexPath.section == 0){
        cell.textLabel.text = _currentMachine.location.name;
    }else if (indexPath.section == 1){
        if ([_currentMachine.condition isEqualToString:@"N/A"] || [_currentMachine.condition isEqualToString:@""]){
            cell.textLabel.text = @"Tap to edit";
        }else{
            cell = [self formatConditionCell:cell machineCondition:nil];
        }
    }else if (indexPath.section == 2){
        MachineCondition *condition = self.machineConditionsArray[indexPath.row];
        
        [self formatConditionCell:cell machineCondition:condition];
    }else if (indexPath.section == 3){
        if (indexPath.row == 0){
            cell.textLabel.text = @"Add your score";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }else{
            MachineScore *score = self.machineScores[indexPath.row-1];
            
            UILabel *scoreLabel = (UILabel *)[cell viewWithTag:100];
            scoreLabel.text = score.scoreString;
            [scoreLabel sizeToFit];
            
            UILabel *scoreDetailLabel = (UILabel *)[cell viewWithTag:101];
            
            NSString *usernameData = @"";
            BOOL usernameEntered = (![score.createdByUsername isKindOfClass:[NSNull class]] || [score.createdByUsername length] > 0);
            
            if (usernameEntered) {
                usernameData = [NSString stringWithFormat:@" by %@", score.createdByUsername];
            }
            
            NSString *unformattedDetail = [NSString stringWithFormat:@"  Scored on: %@%@",[score.dateCreated threeLetterMonthPretty],usernameData];
            NSMutableAttributedString *formattedDetail = [[NSMutableAttributedString alloc] initWithString:unformattedDetail];

            if (usernameEntered) {
                NSRange boldRange = [unformattedDetail rangeOfString:score.createdByUsername];
                
                [formattedDetail setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:scoreDetailLabel.font.pointSize]} range:boldRange];
            }
            
            scoreDetailLabel.attributedText = formattedDetail;
            [scoreDetailLabel sizeToFit];
        }
    }else if (indexPath.section == 4){
        cell.textLabel.text = @"Remove Machine";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1){
        if ([[PinballMapManager sharedInstance] isLoggedInAsGuest]){
            UINavigationController *navController = [[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        } else {
            NSString *string = [NSString stringWithFormat:@"%@ at %@",_currentMachine.machine.name,_currentMachine.location.name];
            TextEditorView *textEditor = [[TextEditorView alloc] initWithTitle:@"Machine Condition" andDelegate:self];
            textEditor.editorPrompt = string;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:textEditor];
            if ([UIDevice iPad]){
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            [self presentViewController:nav animated:YES completion:nil];
            
            return;
        }
    }else if (indexPath.section == 3 && indexPath.row == 0){
        if ([[PinballMapManager sharedInstance] isLoggedInAsGuest]){
            UINavigationController *navController = [[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        } else {
            NewMachineScoreView *scoreView = [[[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"NewMachineScoreView"] viewControllers] lastObject];
            scoreView.currentMachine = _currentMachine;
            scoreView.delegate = self;
            [self.navigationController presentViewController:scoreView.parentViewController animated:YES completion:nil];
        }
    }else if (indexPath.section == 4){
        if ([[PinballMapManager sharedInstance] isLoggedInAsGuest]){
            UINavigationController *navController = [[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        } else {
            self.deletePath = indexPath;
            self.deleteConfirm = [UIAlertView applicationAlertWithMessage:@"Are you sure you want to remove this machine." delegate:self cancelButton:@"No" otherButtons:@"Yes", nil];
            [self.deleteConfirm show];
        }
    }
}
#pragma mark - TextEditor Delegate
- (void)editorDidComplete:(NSString *)text{
    [[PinballMapManager sharedInstance] updateMachineCondition:_currentMachine withCondition:text withCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            _currentMachine.condition = text;
            _currentMachine.conditionUpdate = [NSDate date];
            
            _currentMachine.location.lastUpdatedByUsername =  [status valueForKeyPath:@"location_machine.last_updated_by_username"];
            _currentMachine.updatedByUsername = [status valueForKeyPath:@"location_machine.last_updated_by_username"];
            _currentMachine.location.lastUpdated = [NSDate date];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedMachine" object:nil];
            
            [[CoreDataManager sharedInstance] saveContext];
            [UIAlertView simpleApplicationAlertWithMessage:@"Updated condition" cancelButton:@"Ok"];

            [self reloadPastConditions];
        }
    }];
}
- (void)editorDidCancel{}

@end
