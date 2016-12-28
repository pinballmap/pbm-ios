//
//  LocationProfileView-iPad.m
//  PinballMap
//
//  Created by Frank Michael on 6/9/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationProfileView-iPad.h"
#import "LocationProfileView.h"
#import <MapKit/MapKit.h>
#import "LocationsView.h"
#import "UIViewController+Helpers.h"
#import "LocationAnnotation.h"

typedef NS_ENUM(NSUInteger, LayoutType) {
    LayoutTypeListing = 0,
    LayoutTypeProfile,
    LayoutTypeBrowse,
};

@interface LocationProfileView_iPad () <MKMapViewDelegate>

@property (nonatomic) LocationProfileView *profileViewController;
@property (nonatomic) LocationsView *locationsViewController;
@property (nonatomic) Region *currentRegion;
@property (nonatomic) BOOL isBrowsing;


@property (weak) IBOutlet UIView *locationsListingView;
@property (weak) IBOutlet UIView *locationProfile;
@property (weak) IBOutlet MKMapView *mapView;


@property (weak) IBOutlet NSLayoutConstraint *listingLeft;
@property (weak) IBOutlet NSLayoutConstraint *profileLeft;

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
    if ([[PinballMapManager sharedInstance] currentRegion]){
        self.currentRegion = [[PinballMapManager sharedInstance] currentRegion];
        CLLocationCoordinate2D regionCoord = CLLocationCoordinate2DMake(self.currentRegion.latitude.doubleValue, self.currentRegion.longitude.doubleValue);
        _mapView.region = MKCoordinateRegionMake(regionCoord, MKCoordinateSpanMake(1.0, 1.0));
        _mapView.delegate = self;
    }
    
    [self setupNavigationWithType:LayoutTypeListing];
}
- (void)updateRegion{
    [_mapView removeAnnotations:_mapView.annotations];
    self.currentRegion = [[PinballMapManager sharedInstance] currentRegion];
    if (self.currentRegion){
        CLLocationCoordinate2D regionCoord = CLLocationCoordinate2DMake(self.currentRegion.latitude.doubleValue, self.currentRegion.longitude.doubleValue);
        _mapView.region = MKCoordinateRegionMake(regionCoord, MKCoordinateSpanMake(1.0, 1.0));
        _mapView.delegate = self;

        [self showListingsView:nil];
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setCurrentLocation:(Location *)currentLocation{
    _currentLocation = currentLocation;
    self.profileViewController.currentLocation = _currentLocation;

    if (!self.isBrowsing){
        [_mapView removeAnnotations:_mapView.annotations];
        
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

        _mapView.region = MKCoordinateRegionMake(locationCoord, MKCoordinateSpanMake(0.6, 0.6));
        
        _listingLeft.constant = -321;
        _profileLeft.constant = 0;
        
        [UIView animateWithDuration:.5 animations:^{
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {

        }];
        [self setupNavigationWithType:LayoutTypeProfile];
    
    }else{
        _profileLeft.constant = 0;
        
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}
- (void)browseLocations{
    if (!self.isBrowsing){
        [_mapView removeAnnotations:_mapView.annotations];
        self.isBrowsing = YES;
        NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
        stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        NSArray *locations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:stackRequest error:nil];
        [locations enumerateObjectsUsingBlock:^(Location *location, NSUInteger idx, BOOL *stop) {
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
            [_mapView addAnnotation:locationPin];
        }];
        
        _listingLeft.constant = -322;
        
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        
        [self setupNavigationWithType:LayoutTypeBrowse];
    }else{
        self.isBrowsing = NO;
        [_mapView removeAnnotations:_mapView.annotations];
        [self showListingsView:nil];
    }
    
}
#pragma mark - Class
- (void)setupNavigationWithType:(LayoutType)type{
    
    if (type == LayoutTypeListing){
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.title = self.currentRegion.fullName;
        UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self.locationsViewController action:@selector(filterResults:)];
        UIBarButtonItem *browseLocations = [[UIBarButtonItem alloc] initWithTitle:@"Browse on Map" style:UIBarButtonItemStylePlain target:self action:@selector(browseLocations)];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = 140.0;
        UIBarButtonItem *newLocation = [[UIBarButtonItem alloc] initWithTitle:@"Suggest" style:UIBarButtonItemStylePlain target:self action:@selector(showNewLocationView:)];
        self.navigationItem.leftBarButtonItems = @[filterButton,fixedSpace,browseLocations];
        self.navigationItem.rightBarButtonItem = newLocation;
    }else if (type == LayoutTypeProfile){
        UIBarButtonItem *showListings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"766-arrow-right"] style:UIBarButtonItemStylePlain target:self action:@selector(showListingsView:)];
        self.navigationItem.leftBarButtonItems = @[showListings];
        self.navigationItem.title = _currentLocation.name;
    }else if (type == LayoutTypeBrowse){
        UIBarButtonItem *browseLocations = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(browseLocations)];
        self.navigationItem.leftBarButtonItems = @[browseLocations];
        self.navigationItem.rightBarButtonItems = nil;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[LocationProfileView class]]){
        self.profileViewController = segue.destinationViewController;
    }else if ([segue.destinationViewController isKindOfClass:[LocationsView class]]){
        self.locationsViewController = segue.destinationViewController;
    }
}
#pragma mark - Class Actions
- (IBAction)showListingsView:(id)sender{
    _currentLocation = nil;
    self.profileViewController.currentLocation = nil;

    _profileLeft.constant = -320;
    _listingLeft.constant = 0;

    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {

    }];
    [self setupNavigationWithType:LayoutTypeListing];
    
}
- (IBAction)showNewLocationView:(id)sender{
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"NewLocationView"];
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
        if (!self.isBrowsing){
            pinView.animatesDrop = YES;
        }else{
            pinView.animatesDrop = NO;
        }
        pinView.canShowCallout = YES;
    }else{
        pinView.annotation = annotation;
    }
    return pinView;
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[LocationAnnotation class]]){
        Location *location = [(LocationAnnotation *)view.annotation location];
        if (location) {
            [self setCurrentLocation:location];
        }
    }
}

@end
