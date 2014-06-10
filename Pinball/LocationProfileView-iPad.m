//
//  LocationProfileView-iPad.m
//  Pinball
//
//  Created by Frank Michael on 6/9/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationProfileView-iPad.h"
#import "LocationProfileView.h"
#import <MapKit/MapKit.h>
#import "LocationsView.h"
#import "UIViewController+Helpers.h"

@interface LocationProfileView_iPad () <MKMapViewDelegate>{
    LocationProfileView *profileViewController;
    LocationsView *locationsViewController;
    Region *currentRegion;
}
@property (nonatomic) IBOutlet UIView *locationsListingView;
@property (nonatomic) IBOutlet UIView *locationProfile;
@property (nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation LocationProfileView_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRegion) name:@"RegionUpdate" object:nil];

    // Do any additional setup after loading the view.
    _locationProfile.frame = CGRectMake(1024, 0, CGRectGetWidth(_locationProfile.frame), CGRectGetHeight(_locationProfile.frame));
    
    [self updateRegion];
}
- (void)updateRegion{
    [_mapView removeAnnotations:_mapView.annotations];
    currentRegion = [[PinballManager sharedInstance] currentRegion];
    CLLocationCoordinate2D regionCoord = CLLocationCoordinate2DMake(currentRegion.latitude.doubleValue, currentRegion.longitude.doubleValue);
    _mapView.region = MKCoordinateRegionMake(regionCoord, MKCoordinateSpanMake(1.0, 1.0));
    _mapView.delegate = self;
    if (!_currentLocation){
        self.navigationItem.title = currentRegion.fullName;
        UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"798-filter"] style:UIBarButtonItemStylePlain target:locationsViewController action:@selector(filterResults:)];
        self.navigationItem.leftBarButtonItem = filterButton;
    }
    [self showListingsView:nil];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setCurrentLocation:(Location *)currentLocation{
    [_mapView removeAnnotations:_mapView.annotations];
    _currentLocation = currentLocation;
    profileViewController.currentLocation = _currentLocation;
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:profileViewController action:@selector(editLocation:)];
    self.navigationItem.rightBarButtonItem = editButton;

    CLLocationCoordinate2D locationCoord = CLLocationCoordinate2DMake(_currentLocation.latitude.doubleValue, _currentLocation.longitude.doubleValue);
    MKPointAnnotation *locationPin = [[MKPointAnnotation alloc] init];
    locationPin.title = _currentLocation.name;
    if ([_currentLocation.currentDistance isEqual:@(0)]){
        locationPin.subtitle = nil;
    }else{
        locationPin.subtitle = [NSString stringWithFormat:@"%.02f miles",[_currentLocation.currentDistance floatValue]];
    }
    locationPin.coordinate = locationCoord;
    [_mapView addAnnotation:locationPin];
    [_mapView selectAnnotation:locationPin animated:YES];
    NSLog(@"%f",locationCoord.latitude);
    _mapView.region = MKCoordinateRegionMake(locationCoord, MKCoordinateSpanMake(0.6, 0.6));
    
    [UIView animateWithDuration:.3 animations:^{
        _locationsListingView.frame = CGRectMake(-90, 0, _locationsListingView.frame.size.width, _locationsListingView.frame.size.height);
        _mapView.frame = CGRectMake(0, 0, 703, self.view.frame.size.height);
        _locationProfile.frame = CGRectMake(704, 0, 320, self.view.frame.size.height);
    }];
    
    UIBarButtonItem *showListings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"766-arrow-right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showListingsView:)];
    self.navigationItem.leftBarButtonItem = showListings;

    self.navigationItem.title = _currentLocation.name;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[LocationProfileView class]]){
        profileViewController = segue.destinationViewController;
    }else if ([segue.destinationViewController isKindOfClass:[LocationsView class]]){
        locationsViewController = segue.destinationViewController;
    }
}
#pragma mark - Class Actions
- (IBAction)showListingsView:(id)sender{
    _currentLocation = nil;
    [UIView animateWithDuration:.3 animations:^{
        _locationsListingView.frame = CGRectMake(0, 0, _locationsListingView.frame.size.width, _locationsListingView.frame.size.height);
        _mapView.frame = CGRectMake(321, 0, 703, self.view.frame.size.height);
        _locationProfile.frame = CGRectMake(1024, 0, CGRectGetWidth(_locationProfile.frame), CGRectGetHeight(_locationProfile.frame));
    }];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = currentRegion.fullName;
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"798-filter"] style:UIBarButtonItemStylePlain target:locationsViewController action:@selector(filterResults:)];
    self.navigationItem.leftBarButtonItem = filterButton;
    UIBarButtonItem *newLocation = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewLocationView:)];
    self.navigationItem.rightBarButtonItem = newLocation;
}
- (IBAction)showNewLocationView:(id)sender{
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewLocationView"];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}
#pragma mark - Map Annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    MKPinAnnotationView *pinView =(MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"locpin"];
    if (!pinView){
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"locpin"];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }else{
        pinView.annotation = annotation;
    }
    return pinView;
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
