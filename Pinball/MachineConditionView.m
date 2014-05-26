//
//  MachineConditionView.m
//  Pinball
//
//  Created by Frank Michael on 4/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineConditionView.h"
#import "UIAlertView+Application.h"

@interface MachineConditionView () <UITextViewDelegate> {
    IBOutlet UITextView *machineCondition;
    IBOutlet UILabel *locationName;
}
- (IBAction)cancelCondition:(id)sender;
- (IBAction)saveCondition:(id)sender;

@end

@implementation MachineConditionView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setCurrentMachine:(MachineLocation *)currentMachine{
    _currentMachine = currentMachine;
    [self setupUI];
}
#pragma mark - Class
- (void)setupUI{
    locationName.text = _currentMachine.location.name;
    if (![_currentMachine.condition isEqualToString:@"N/A"]){
        machineCondition.text = _currentMachine.condition;
    }
}
#pragma mark - Class Actions
- (IBAction)cancelCondition:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveCondition:(id)sender{
    [[PinballManager sharedInstance] updateMachineCondition:_currentMachine withCondition:machineCondition.text withCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            _currentMachine.condition = machineCondition.text;
            _currentMachine.conditionUpdate = [NSDate date];
            [[CoreDataManager sharedInstance] saveContext];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return _currentMachine.machine.name;
    }else{
        return @"Location";
    }
}
#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Machine Condition"]){
        textView.text = @"";
    }
}
- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text rangeOfString:@"\n"].location != NSNotFound){
        [textView resignFirstResponder];
    }
}
@end
