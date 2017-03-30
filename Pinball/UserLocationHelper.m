//
//  UserLocationHelper.m
//  CoreLocationHelper
//
//  Created by Frank Michael on 3/2/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "UserLocationHelper.h"

@interface UserLocationHelper () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong)LocationUpdated completionBlock;

@end

@implementation UserLocationHelper

- (void)getUserLocationWithCompletion:(LocationUpdated)block{
    self.completionBlock = block;
    if (!self.locationManager){
        self.locationManager = [CLLocationManager new];
    }
    // iOS 8 Support for location updating
    NSLog(@"%i",[CLLocationManager authorizationStatus]);
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways){
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5;
    [self.locationManager startUpdatingLocation];
}
#pragma mark - CLLocationManager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"Location updated.");
    CLLocation *foundLocation = [locations lastObject];
    if (self.completionBlock){
        self.completionBlock(foundLocation);
    }
    [manager stopUpdatingLocation];
}

@end
