//
//  NearbyView.m
//  PinballMap
//
//  Created by Frank Michael on 9/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NearbyView.h"
#import <MapKit/MapKit.h>
#import "Location+UpdateDistance.h"
#import "Location+Annotation.h"

@interface NearbyView ()

@property (nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation NearbyView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Nearby";
    self.mapView.showsUserLocation = YES;
    CLLocation *location = [[PinballMapManager sharedInstance] userLocation];
    if (location){
        [self.mapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.04, .04))];
        [Location updateAllForRegion:[[PinballMapManager sharedInstance] currentRegion]];
        NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        stackRequest.predicate = [NSPredicate predicateWithFormat:@"region.name = %@",[[[PinballMapManager sharedInstance] currentRegion] name]];
        stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationDistance" ascending:YES]];
        stackRequest.fetchLimit = 20;
        NSArray *locations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:stackRequest error:nil];
        
        for (Location *location in locations) {
            [self.mapView addAnnotation:location.annotation];
            
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
