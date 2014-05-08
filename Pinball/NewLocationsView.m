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
            [UIAlertView simpleApplicationAlertWithMessage:[NSString stringWithFormat:@"%@ must be set.",field[@"display"]]cancelButton:@"Ok"];
            infoStatus = NO;
            *stop = true;
        }
    }];
    return infoStatus;
}
#pragma mark - Class Actions
- (IBAction)saveLocation:(id)sender{
    if ([self checkInformation]){
        #pragma message("TODO: API Interaction for adding a location.")
        [self dismissViewControllerAnimated:YES completion:nil];
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
