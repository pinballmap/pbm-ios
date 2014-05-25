//
//  NewLocationsView.m
//  Pinball
//
//  Created by Frank Michael on 4/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewLocationsView.h"
@import CoreLocation;
@import AddressBook; // Do this so we can easily pull out the address keys from the geocoder.
#import "UIAlertView+Application.h"
#import "MachinePickingView.h"

@interface NewLocationsView () <CLLocationManagerDelegate,PickingDelegate> {
    // Basic Information
    IBOutlet UITextField *locationName;
    IBOutlet UITextField *locationPhone;
    IBOutlet UITextField *locationWebsite;
    IBOutlet UITextField *locationOperator;
    IBOutlet UILabel *machineLabel;
    IBOutlet UITextField *userName;
    IBOutlet UITextField *userEmail;
    // Location information
    IBOutlet UITextField *locationStreet;
    IBOutlet UITextField *locationCity;
    IBOutlet UITextField *locationState;
    IBOutlet UITextField *locationZip;
    NSArray *formFields;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    NSMutableArray *pickedMachines;
}
- (IBAction)saveLocation:(id)sender;
- (IBAction)cancelLocation:(id)sender;
- (void)useCurrentLocation;
@end

@implementation NewLocationsView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    formFields = @[@{@"display": @"Name", @"field": locationName},
                   @{@"display": @"Phone", @"field": locationPhone},
                   @{@"display": @"Website", @"field": locationWebsite},
                   @{@"display": @"Operator", @"field": locationOperator},
                   @{@"display": @"Street", @"field": locationStreet},
                   @{@"display": @"City", @"field": locationCity},
                   @{@"display": @"State", @"field": locationState},
                   @{@"display": @"Zip", @"field": locationZip}];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class
- (void)useCurrentLocation{
    if (!locationManager){
        locationManager = [CLLocationManager new];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}
- (BOOL)checkInformation{
    __block BOOL infoStatus;
    [formFields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *field = obj;
        if ([(UITextField *)field[@"field"] text].length == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView simpleApplicationAlertWithMessage:[NSString stringWithFormat:@"%@ must be set.",field[@"display"]]cancelButton:@"Ok"];
            });
            infoStatus = NO;
            *stop = true;
        }
    }];
    return infoStatus;
}
#pragma mark - Class Actions
- (IBAction)saveLocation:(id)sender{
    if ([self checkInformation]){
        NSDictionary *suggestingInfo = @{@"region_id": [[[PinballManager sharedInstance] currentRegion] regionId],
                                         @"location_name": locationName.text,
                                         @"location_street": locationStreet.text,
                                         @"location_city": locationCity.text,
                                         @"location_state": locationState.text,
                                         @"location_zip": locationZip.text,
                                         @"location_phone": locationPhone.text,
                                         @"location_website": locationWebsite.text,
                                         @"location_operator": locationOperator.text,
                                         @"location_machines": @"Machine names",
                                         @"submitter_name" : userName.text,
                                         @"submitter_email": userEmail.text};
        [[PinballManager sharedInstance] suggestLocation:suggestingInfo andCompletion:^(NSDictionary *status) {
            if (status[@"errors"]){
                NSString *errors;
                if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                    errors = [status[@"errors"] componentsJoinedByString:@","];
                }else{
                    errors = status[@"errors"];
                }
                [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
            }else{
                [UIAlertView simpleApplicationAlertWithMessage:status[@"response"] cancelButton:@"Ok"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}
- (IBAction)cancelLocation:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if (indexPath.row == 4){
            MachinePickingView *pickingView = [[(UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MachinePickingView"] viewControllers] lastObject];
            pickingView.delegate = self;
            pickingView.canPickMultiple = YES;
            if (pickedMachines.count > 0){
                pickingView.pickedMachines = pickedMachines;
            }
            [self presentViewController:pickingView.parentViewController animated:YES completion:nil];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0){
            // Use current location.
            [self useCurrentLocation];
        }
    }
}
#pragma mark - PickingDelegate
- (void)pickedMachines:(NSArray *)machines{
    if (!machines){
        return;
    }
    if (!pickedMachines){
        pickedMachines = [NSMutableArray new];
    }
    [pickedMachines removeAllObjects];
    [pickedMachines addObjectsFromArray:machines];
    machineLabel.text = [NSString stringWithFormat:@"Add Machine (%lu)",(unsigned long)pickedMachines.count];
}
#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *foundLocation = [locations lastObject];
    NSDate* eventDate = foundLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        [self reverseGeocode:foundLocation];
        [manager stopUpdatingLocation];
    }
}
#pragma mark - GeocoderDelegate
- (void)reverseGeocode:(CLLocation *)location{
    if (!geocoder){
        geocoder = [CLGeocoder new];
    }
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error){
            if (placemarks.count > 0){
                CLPlacemark *placemark = [placemarks firstObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    locationStreet.text = placemark.addressDictionary[@"Street"];
                    locationCity.text = placemark.addressDictionary[@"City"];
                    locationState.text = placemark.addressDictionary[@"State"];
                    locationZip.text = placemark.addressDictionary[@"ZIP"];
                });
            }
        }
    }];
}
@end
