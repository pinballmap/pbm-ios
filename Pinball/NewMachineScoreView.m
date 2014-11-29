//
//  NewMachineScoreView.m
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewMachineScoreView.h"
#import "UIAlertView+Application.h"

@interface NewMachineScoreView () <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic) NSArray *ranks;
@property (nonatomic) NSDictionary *pickedRank;
@property (nonatomic) UIPickerView *rankPicker;
@property (weak) IBOutlet UITextField *score;
@property (weak) IBOutlet UITextField *initials;
@property (weak) IBOutlet UITextField *rank;

- (IBAction)saveScore:(id)sender;
- (IBAction)cancelScore:(id)sender;

@end

@implementation NewMachineScoreView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    _rankPicker = [[UIPickerView alloc] init];
    _rankPicker.dataSource = self;
    _rankPicker.delegate = self;
    self.ranks = @[@{@"id": @1,@"name": @"GC"},
              @{@"id": @2,@"name": @"1st"},
              @{@"id": @3,@"name": @"2nd"},
              @{@"id": @4,@"name": @"3rd"},
              @{@"id": @5,@"name": @"4th"}];
    _rank.inputView = _rankPicker;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class Actions
- (IBAction)saveScore:(id)sender{
    NSDictionary *scoreData = @{@"location_machine_xref_id": _currentMachine.machineLocationId,@"score":_score.text,@"rank":self.pickedRank[@"id"],@"initials":_initials.text};
    [[PinballMapManager sharedInstance] addScore:scoreData forMachine:_currentMachine withCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            if (_delegate){
                [_delegate didAddScore];
            }
            [UIAlertView simpleApplicationAlertWithMessage:status[@"msg"] cancelButton:@"Ok"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
- (IBAction)cancelScore:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Picker View DataSource/Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.ranks.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.ranks[row][@"name"];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.pickedRank = self.ranks[row];
    _rank.text = self.pickedRank[@"name"];
}

@end
