//
//  NewEventView.m
//  Pinball
//
//  Created by Frank Michael on 4/20/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewEventView.h"
#import "LocationsView.h"

@interface NewEventView () <UITextFieldDelegate> {
    IBOutlet UITextField *eventTitle;
    IBOutlet UITextField *eventDesc;
    IBOutlet UITextField *eventLink;
    IBOutlet UITextField *eventDate;
    IBOutlet UILabel *locationName;
    IBOutlet UITextField *locationStreet;
    IBOutlet UITextField *locationCity;
    IBOutlet UITextField *locationState;
}
- (IBAction)cancelEvent:(id)sender;
- (IBAction)saveEvent:(id)sender;

@end

@implementation NewEventView

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
#pragma mark - Class actions
- (IBAction)cancelEvent:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveEvent:(id)sender{
    #pragma message("TODO: API interaction for adding a event")
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Class
- (void)setLocation:(Location *)location{
    _location = location;
    locationName.text = _location.name;
    locationStreet.text = _location.street;
    locationCity.text = _location.city;
    locationState.text = _location.state;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"LocationSelect"]){
        LocationsView *locations = segue.destinationViewController;
        locations.isSelecting = YES;
        locations.selectingViewController = self;
    }
}
#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == eventDate){
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.date = [NSDate date];
        datePicker.minimumDate = [NSDate date];
        textField.inputView = datePicker;
    }
}

@end
