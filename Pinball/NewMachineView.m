//
//  NewMachineView.m
//  Pinball
//
//  Created by Frank Michael on 5/10/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewMachineView.h"
#import "UIAlertView+Application.h"

@interface NewMachineView () {
    
}
@property (nonatomic) IBOutlet UITextField *machineName;
@property (nonatomic) IBOutlet UITextField *machineYear;
@property (nonatomic) IBOutlet UITextField *machineManufacturer;

- (IBAction)saveMachine:(id)sender;
- (IBAction)cancelMachine:(id)sender;
@end

@implementation NewMachineView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class Actions
- (IBAction)saveMachine:(id)sender{
    if ([self checkMachineForm]){
        NSDictionary *machine = @{@"name": _machineName.text,@"year": _machineYear.text,@"manufacturer":_machineManufacturer.text};
        #pragma message("TODO: API Interaction for adding a new machine.")
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)cancelMachine:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Class
- (BOOL)checkMachineForm{
    if (_machineYear.text.length != 4){
        [UIAlertView simpleApplicationAlertWithMessage:@"The year must be set." cancelButton:@"Ok"];
        return NO;
    }else if (_machineName.text.length == 0){
        [UIAlertView simpleApplicationAlertWithMessage:@"You must set the machine name." cancelButton:@"Ok"];
        return NO;
    }else if (_machineManufacturer.text.length == 0){
        [UIAlertView simpleApplicationAlertWithMessage:@"You must set the manufacturer." cancelButton:@"Ok"];
        return NO;
    }
    return YES;
}
@end