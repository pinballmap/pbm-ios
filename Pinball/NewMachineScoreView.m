//
//  NewMachineScoreView.m
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewMachineScoreView.h"
#import "UIAlertView+Application.h"

@interface NewMachineScoreView ()
@property (weak) IBOutlet UITextField *score;

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
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class Actions
- (IBAction)saveScore:(id)sender{
    if (self.score.text.length == 0){
        [UIAlertView simpleApplicationAlertWithMessage:@"You must enter a valid score" cancelButton:@"Ok"];
        return;
    }
    NSDictionary *scoreData = @{@"location_machine_xref_id": _currentMachine.machineLocationId,@"score":_score.text};
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
            _currentMachine.location.lastUpdatedByUsername = [[PinballMapManager sharedInstance] currentUser].username;
            _currentMachine.location.lastUpdated = [NSDate date];
            
            [[CoreDataManager sharedInstance] saveContext];

            [UIAlertView simpleApplicationAlertWithMessage:status[@"msg"] cancelButton:@"Ok"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
- (IBAction)cancelScore:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
