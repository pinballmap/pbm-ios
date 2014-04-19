//
//  NewMachineView.m
//  Pinball
//
//  Created by Frank Michael on 4/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewMachineView.h"
#import "LocationsView.h"
#import "UIAlertView+Application.h"

@interface NewMachineView () {
    IBOutlet UITextField *machineName;
    IBOutlet UILabel *locationName;
}
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
    locationName.text = _machineLocation.name;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"LocationSelect"]){
        LocationsView *locations = segue.destinationViewController;
        locations.isSelecting = YES;
        locations.selectingViewController = self;
    }
}
- (void)setMachineLocation:(Location *)machineLocation{
    _machineLocation = machineLocation;
    locationName.text = _machineLocation.name;
}
#pragma mark - Actions
- (IBAction)saveMachine:(id)sender{
    if (_machineLocation && machineName.text.length > 0){
        #pragma message("TODO: API Interaction for adding machines.")
        NSDictionary *machine = @{@"name": machineName.text,@"location": _machineLocation};
        NSLog(@"%@",machine);
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        if (machineName.text.length == 0){
            [UIAlertView simpleApplicationAlertWithMessage:@"You must enter a machine name." cancelButton:@"Ok"];
        }else if (!_machineLocation){
            [UIAlertView simpleApplicationAlertWithMessage:@"You must select a location for this machine." cancelButton:@"Ok"];
        }
    }
}
- (IBAction)cancelMachine:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
