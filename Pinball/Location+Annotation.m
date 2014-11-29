//
//  Location+Annotation.m
//  PinballMap
//
//  Created by Frank Michael on 9/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location+Annotation.h"

@implementation Location (Annotation)

- (MKPointAnnotation *)annotation{
    MKPointAnnotation *locationAnnotation = [[MKPointAnnotation alloc] init];
    locationAnnotation.title = self.name;
    if ([self.currentDistance isEqual:@(0)]){
        locationAnnotation.subtitle = nil;
    }else{
        locationAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles",[self.currentDistance floatValue]];
    }
    locationAnnotation.coordinate = self.clCoordinate;

    return locationAnnotation;
}
- (CLLocationCoordinate2D)clCoordinate{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

@end
