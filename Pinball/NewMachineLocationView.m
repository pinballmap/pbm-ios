//
//  NewMachineView.m
//  Pinball
//
//  Created by Frank Michael on 4/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewMachineLocationView.h"
#import "LocationsView.h"
#import "UIAlertView+Application.h"
#import "MachinePickingView.h"

@interface NewMachineLocationView () <PickingDelegate,UITextViewDelegate>{
    IBOutlet UILabel *machineName;
    IBOutlet UILabel *locationName;
    IBOutlet UITextView *machineCondition;
    Machine *pickedMachine;
}
- (IBAction)saveMachine:(id)sender;
- (IBAction)cancelMachine:(id)sender;
@end

@implementation NewMachineLocationView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    locationName.text = _location.name;
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
    }else if ([segue.identifier isEqualToString:@"MachineSelect"]){
        MachinePickingView *pickingView = [[segue.destinationViewController viewControllers] lastObject];
        pickingView.delegate = self;
        pickingView.canPickMultiple = NO;
    }
}
- (void)setLocation:(Location *)location{
    _location = location;
    locationName.text = _location.name;
}
#pragma mark - Machine Picking View Delegate
- (void)pickedMachines:(NSArray *)machines{
    pickedMachine = [machines lastObject];
    machineName.text = pickedMachine.name;
}
#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        MachinePickingView *pickingView = [[[self.storyboard instantiateViewControllerWithIdentifier:@"MachinePickingView"] viewControllers] lastObject];
        pickingView.delegate = self;
        pickingView.canPickMultiple = NO;
        [self.navigationController presentViewController:pickingView.parentViewController animated:YES completion:nil];
    }
}
#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Condition"]){
        textView.text = @"";
    }
}
#pragma mark - Actions
- (IBAction)saveMachine:(id)sender{
    if (_location && machineName.text.length > 0){
        #pragma message("TODO: API Interaction for adding machines.")
        NSDictionary *machine = @{@"name": pickedMachine.machineId,@"location": _location.locationId,@"condition": machineCondition.text};
        NSLog(@"%@",machine);
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        if (machineName.text.length == 0){
            [UIAlertView simpleApplicationAlertWithMessage:@"You must enter a machine name." cancelButton:@"Ok"];
        }else if (!_location){
            [UIAlertView simpleApplicationAlertWithMessage:@"You must select a location for this machine." cancelButton:@"Ok"];
        }
    }
}
- (IBAction)cancelMachine:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
