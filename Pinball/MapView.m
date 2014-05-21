//
//  LocationMapView.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MapView.h"
@import MapKit;
@import AddressBook;
#import "MachineLocation.h"
#import "MachineLocationPin.h"
#import "LocationProfileView.h"

@interface MapView () <MKMapViewDelegate> {
    IBOutlet MKMapView *mainMapView;
}
- (IBAction)showInMaps:(id)sender;
- (IBAction)dismissMap:(id)sender;
@end

@implementation MapView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mainMapView.delegate = self;
    if (self.presentingViewController){
        UIBarButtonItem *doneMap = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissMap:)];
        self.navigationItem.leftBarButtonItem = doneMap;
    }
    
    if (_currentLocation){
        self.navigationItem.title = [NSString stringWithFormat:@"%@",_currentLocation.name];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue],[_currentLocation.longitude doubleValue]);
        mainMapView.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.002, 0.002));
        
        MKPointAnnotation *locationPin = [[MKPointAnnotation alloc] init];
        locationPin.title = _currentLocation.name;
        locationPin.coordinate = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue], [_currentLocation.longitude doubleValue]);
        [mainMapView addAnnotation:locationPin];
    }else if (_currentMachine) {
        [_currentMachine.machineLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MachineLocation *loc = obj;
            MachineLocationPin *annotation = [[MachineLocationPin alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake([loc.location.latitude doubleValue],[loc.location.longitude doubleValue]);
            annotation.title = loc.location.name;
            annotation.subtitle = loc.location.street;
            annotation.currentMachine = loc;
            [mainMapView addAnnotation:annotation];
            mainMapView.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(1.0, 1.0));
        }];
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"locpin"];
    if (!pinView){
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"locpin"];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        if ([annotation isKindOfClass:[MachineLocationPin class]]){
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
        }
    }else{
        pinView.annotation = annotation;
    }
    return pinView;
}
- (IBAction)dismissMap:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showInMaps:(id)sender{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue],[_currentLocation.longitude doubleValue]);
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[_currentLocation.street,_currentLocation.city,_currentLocation.state,_currentLocation.zip] forKeys:[NSArray arrayWithObjects:(NSString *)kABPersonAddressStreetKey,kABPersonAddressCityKey,kABPersonAddressStateKey,kABPersonAddressZIPKey, nil]];

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:dic];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    [MKMapItem openMapsWithItems:@[item] launchOptions:nil];
}
#pragma mark - Machine Map
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    LocationProfileView *locationProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationProfileView"];
    locationProfile.currentLocation = [[(MachineLocationPin *)view.annotation currentMachine] location];
    [self.navigationController pushViewController:locationProfile animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
