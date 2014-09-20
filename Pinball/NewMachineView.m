//
//  NewMachineView.m
//  PinballMap
//
//  Created by Frank Michael on 5/10/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewMachineView.h"
#import "UIAlertView+Application.h"
#import "LocationsView.h"

@interface NewMachineView ()

@property (nonatomic) Location *selectedLocation;
@property (weak) IBOutlet UITextField *machineName;
@property (weak) IBOutlet UILabel *locationTitle;

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
    if (self.selectedLocation && _machineName.text.length > 0){
        NSDictionary *machineData = @{@"machine_name": _machineName.text,@"location_id": self.selectedLocation.locationId};
        [[PinballMapManager sharedInstance] createNewMachine:machineData withCompletion:^(NSDictionary *status) {
            if (status[@"errors"]){
                NSString *errors;
                if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                    errors = [status[@"errors"] componentsJoinedByString:@","];
                }else{
                    errors = status[@"errors"];
                }
                [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
            }else{
                [UIAlertView simpleApplicationAlertWithMessage:@"New machine received!" cancelButton:@"Ok"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}
- (IBAction)cancelMachine:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Class
- (void)setLocation:(Location *)location{
    self.selectedLocation = location;
    _locationTitle.text = location.name;
}
#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1){
        LocationsView *locations = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationsView"];
        locations.isSelecting = YES;
        locations.selectingViewController = self;
        [self.navigationController pushViewController:locations animated:YES];
    }
    
}
@end