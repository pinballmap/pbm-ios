//
//  NewMachineView.m
//  PinballMap
//
//  Created by Frank Michael on 4/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewMachineLocationView.h"
#import "LocationsView.h"
#import "UIAlertView+Application.h"
#import "MachinePickingView.h"

@interface NewMachineLocationView () <PickingDelegate,UITextViewDelegate>

@property (nonatomic) Machine *pickedMachine;
@property (weak) IBOutlet UILabel *machineName;
@property (weak) IBOutlet UILabel *locationName;
@property (weak) IBOutlet UITextView *machineCondition;

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
    self.locationName.text = _location.name;
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
    self.locationName.text = _location.name;
}
#pragma mark - Machine Picking View Delegate
- (void)pickedMachines:(NSArray *)machines{
    if (machines.count > 0){
        self.pickedMachine = [machines lastObject];
        self.machineName.text = self.pickedMachine.name;
    }
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
    if (_location.locationId != nil && self.pickedMachine.machineId != nil && ![self.machineName.text isEqualToString:@"Pick Machine"]){
        NSDictionary *machine = @{@"machine_id": self.pickedMachine.machineId,@"location_id": _location.locationId,@"condition": self.machineCondition.text};
        [[PinballMapManager sharedInstance] createNewMachineWithData:machine andParentMachine:self.pickedMachine forLocation:_location withCompletion:^(NSDictionary *status) {
            if (status[@"errors"]){
                NSString *errors;
                if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                    errors = [status[@"errors"] componentsJoinedByString:@","];
                }else{
                    errors = status[@"errors"];
                }
                [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
            }else{
                [UIAlertView simpleApplicationAlertWithMessage:@"Added Machine" cancelButton:@"Ok"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }else{
        if ([self.machineName.text isEqualToString:@"Pick Machine"]){
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
