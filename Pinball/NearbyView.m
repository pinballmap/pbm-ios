//
//  NearbyView.m
//  PinballMap
//
//  Created by Frank Michael on 9/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NearbyView.h"
#import <MapKit/MapKit.h>
#import "UIAlertView+Application.h"
#import "Location+UpdateDistance.h"
#import "Location+Annotation.h"

@interface NearbyView () <MKMapViewDelegate,UIActionSheetDelegate>

@property (weak) IBOutlet MKMapView *mapView;
@property (nonatomic) NSNumber *filterDistance;

@end

@implementation NearbyView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Nearby";
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.mapView.showsUserLocation = YES;
    self.filterDistance = @(10);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRegion) name:@"RegionUpdate" object:nil];
    [self updateRegion];
    
    UIBarButtonItem *filterDistance = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"798-filter"] style:UIBarButtonItemStylePlain target:self action:@selector(updateFilter:)];
//    self.navigationItem.leftBarButtonItem = filterDistance;
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateRegion{
    CLLocation *location = [[PinballMapManager sharedInstance] userLocation];
    if (location){
        [self.mapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.04, .04))];
        [Location updateAllForRegion:[[PinballMapManager sharedInstance] currentRegion]];
        NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND locationDistance <= %@",[[[PinballMapManager sharedInstance] currentRegion] name],self.filterDistance];
        stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationDistance" ascending:YES]];
//        stackRequest.fetchLimit = 20;
        NSArray *locations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:stackRequest error:nil];
        if (locations.count != 0){
            for (Location *location in locations) {
                [self.mapView addAnnotation:location.annotation];
            }
        }else{
            [UIAlertView simpleApplicationAlertWithMessage:@"No locations found nearby" cancelButton:@"Ok"];
        }
    }
}
#pragma mark - Class Actions
- (IBAction)updateFilter:(id)sender{
    UIActionSheet *filterSheet = [[UIActionSheet alloc] initWithTitle:@"Filter Distance" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"10 Miles",@"20 Miles",@"30 Miles",@"40 Miles",@"50 Miles", nil];
    [filterSheet showFromTabBar:self.tabBarController.tabBar];
}
#pragma mark - Action Sheet Deleaget
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        if (buttonIndex == 0){
            self.filterDistance = @(10);
        }else if (buttonIndex == 1){
            self.filterDistance = @(20);
        }else if (buttonIndex == 2){
            self.filterDistance = @(30);
        }else if (buttonIndex == 3){
            self.filterDistance = @(40);
        }else if (buttonIndex == 4){
            self.filterDistance = @(50);
        }
        
        [self updateRegion];
    }
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



@end
