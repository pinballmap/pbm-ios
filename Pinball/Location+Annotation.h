//
//  Location+Annotation.h
//  PinballMap
//
//  Created by Frank Michael on 9/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location.h"
#import <MapKit/MapKit.h>

@interface Location (Annotation)

- (MKPointAnnotation *)annotation;
- (CLLocationCoordinate2D)clCoordinate;
@end
