//
//  NewLocationsView.m
//  PinballMap
//
//  Created by Frank Michael on 4/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NewLocationsView.h"
@import CoreLocation;
@import AddressBook;
#import "UIAlertView+Application.h"
#import "MachinePickingView.h"

@interface NewLocationsView () <CLLocationManagerDelegate,PickingDelegate>

@property (weak) IBOutlet UITextField *locationName;
@property (weak) IBOutlet UITextField *locationPhone;
@property (weak) IBOutlet UITextField *locationWebsite;
@property (weak) IBOutlet UITextField *locationOperator;
@property (weak) IBOutlet UITextField *locationStreet;
@property (weak) IBOutlet UITextField *locationCity;
@property (weak) IBOutlet UITextField *locationState;
@property (weak) IBOutlet UITextField *locationZip;
@property (weak) IBOutlet UILabel *machineLabel;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) NSMutableArray *pickedMachines;

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
    self.navigationItem.prompt = [[[PinballMapManager sharedInstance] currentRegion] fullName];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class
- (void)useCurrentLocation{
    if (!self.locationManager){
        self.locationManager = [CLLocationManager new];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}
#pragma mark - Class Actions
- (IBAction)saveLocation:(id)sender{

    __block NSString *pickedMachineNames = @"";
    [self.pickedMachines enumerateObjectsUsingBlock:^(Machine *obj, NSUInteger idx, BOOL *stop) {
        pickedMachineNames = [pickedMachineNames stringByAppendingString:[NSString stringWithFormat:@"%@ (%@, %@),",obj.name,obj.manufacturer,obj.year]];
    }];
    
    if (self.locationName.text.length > 0 && self.pickedMachines.count > 0){
        NSDictionary *suggestingInfo = @{@"region_id": [[[PinballMapManager sharedInstance] currentRegion] regionId],
                                         @"location_name": self.locationName.text,
                                         @"location_street": self.locationStreet.text,
                                         @"location_city": self.locationCity.text,
                                         @"location_state": self.locationState.text,
                                         @"location_zip": self.locationZip.text,
                                         @"location_phone": self.locationPhone.text,
                                         @"location_website": self.locationWebsite.text,
                                         @"location_operator": self.locationOperator.text,
                                         @"location_machines": pickedMachineNames};
        [[PinballMapManager sharedInstance] suggestLocation:suggestingInfo andCompletion:^(NSDictionary *status) {
            if (status[@"errors"]){
                NSString *errors;
                if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                    errors = [status[@"errors"] componentsJoinedByString:@","];
                }else{
                    errors = status[@"errors"];
                }
                [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
            }else{
                [UIAlertView simpleApplicationAlertWithMessage:status[@"msg"] cancelButton:@"Ok"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }else{
        [UIAlertView simpleApplicationAlertWithMessage:@"You must enter a name and pick at least one machine." cancelButton:@"Ok"];
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
            MachinePickingView *pickingView = [[(UINavigationController *)[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"MachinePickingView"] viewControllers] lastObject];
            pickingView.delegate = self;
            pickingView.canPickMultiple = YES;
            if (self.pickedMachines.count > 0){
                pickingView.existingPickedMachines = self.pickedMachines;
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
    if (!self.pickedMachines){
        self.pickedMachines = [NSMutableArray new];
    }
    [self.pickedMachines removeAllObjects];
    [self.pickedMachines addObjectsFromArray:machines];
    self.machineLabel.text = [NSString stringWithFormat:@"Add Machine (%lu)",(unsigned long)self.pickedMachines.count];
}
#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *foundLocation = [locations lastObject];
    NSDate* eventDate = foundLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        [self reverseGeocode:foundLocation];
        [manager stopUpdatingLocation];
    }
}
#pragma mark - GeocoderDelegate
- (void)reverseGeocode:(CLLocation *)location{
    if (!self.geocoder){
        self.geocoder = [CLGeocoder new];
    }
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error){
            if (placemarks.count > 0){
                CLPlacemark *placemark = [placemarks firstObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.locationStreet.text = placemark.addressDictionary[@"Street"];
                    self.locationCity.text = placemark.addressDictionary[@"City"];
                    self.locationState.text = placemark.addressDictionary[@"State"];
                    self.locationZip.text = placemark.addressDictionary[@"ZIP"];
                });
            }
        }
    }];
}
@end
