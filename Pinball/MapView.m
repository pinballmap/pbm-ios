//
//  LocationMapView.m
//  PinballMap
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
#import "LocationAnnotation.h"


@interface MapView () <MKMapViewDelegate>

@property (weak) IBOutlet MKMapView *mainMapView;

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
    self.mainMapView.delegate = self;
    if (self.presentingViewController){
        UIBarButtonItem *doneMap = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissMap:)];
        self.navigationItem.leftBarButtonItem = doneMap;
    }
    
    if (_currentLocation){
        UIBarButtonItem *openInMap = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showInMaps:)];
        self.navigationItem.rightBarButtonItem = openInMap;
    }
    
    if (_currentLocation){
        self.navigationItem.title = [NSString stringWithFormat:@"%@",_currentLocation.name];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue],[_currentLocation.longitude doubleValue]);
        self.mainMapView.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.002, 0.002));
        
        MKPointAnnotation *locationPin = [[MKPointAnnotation alloc] init];
        locationPin.title = _currentLocation.name;
        locationPin.coordinate = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue], [_currentLocation.longitude doubleValue]);
        [self.mainMapView addAnnotation:locationPin];
    }else if (_currentMachine) {
        [_currentMachine.machineLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MachineLocation *loc = obj;
            MachineLocationPin *annotation = [[MachineLocationPin alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake([loc.location.latitude doubleValue],[loc.location.longitude doubleValue]);
            annotation.title = loc.location.name;
            annotation.subtitle = loc.location.street;
            annotation.currentMachine = loc;
            [self.mainMapView addAnnotation:annotation];
            self.mainMapView.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(1.0, 1.0));
        }];
    }else if (_locations){
        Region *currentRegion = [[PinballMapManager sharedInstance] currentRegion];
        CLLocationCoordinate2D regionCoord = CLLocationCoordinate2DMake(currentRegion.latitude.doubleValue, currentRegion.longitude.doubleValue);
        self.mainMapView.region = MKCoordinateRegionMake(regionCoord, MKCoordinateSpanMake(1.0, 1.0));
        
        
        [_locations enumerateObjectsUsingBlock:^(Location *location, NSUInteger idx, BOOL *stop) {
            CLLocationCoordinate2D locationCoord = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
            LocationAnnotation *locationPin = [[LocationAnnotation alloc] init];
            locationPin.title = location.name;
            locationPin.location = location;
            if ([location.currentDistance isEqual:@(0)]){
                locationPin.subtitle = nil;
            }else{
                locationPin.subtitle = [NSString stringWithFormat:@"%.02f miles",[location.currentDistance floatValue]];
            }
            locationPin.coordinate = locationCoord;
            [self.mainMapView addAnnotation:locationPin];
        }];
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"locpin"];
    if (!pinView){
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"locpin"];
        pinView.pinColor = MKPinAnnotationColorRed;
        // Only animate if we are not browsing.
        if (_locations){
            
        }else{
            pinView.animatesDrop = YES;
        }
        pinView.canShowCallout = YES;
        if ([annotation isKindOfClass:[MachineLocationPin class]] ||[annotation isKindOfClass:[LocationAnnotation class]]){
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
    if (_currentLocation){
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue],[_currentLocation.longitude doubleValue]);
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[_currentLocation.street,_currentLocation.city,_currentLocation.state,_currentLocation.zip] forKeys:[NSArray arrayWithObjects:(NSString *)kABPersonAddressStreetKey,kABPersonAddressCityKey,kABPersonAddressStateKey,kABPersonAddressZIPKey, nil]];

        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:dic];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        [MKMapItem openMapsWithItems:@[item] launchOptions:nil];
    }
}
#pragma mark - Machine Map
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    LocationProfileView *locationProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationProfileView"];
    Location *pinLocation;
    if ([view.annotation isKindOfClass:[MachineLocationPin class]]){
        pinLocation = [[(MachineLocationPin *)view.annotation currentMachine] location];
    }else if ([view.annotation isKindOfClass:[LocationAnnotation class]]){
        pinLocation = [(LocationAnnotation *)view.annotation location];
    }
    locationProfile.currentLocation = pinLocation;
    [self.navigationController pushViewController:locationProfile animated:YES];
}


@end
