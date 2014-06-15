//
//  LocationAnnotation.h
//  PinballMap
//
//  Created by Frank Michael on 6/10/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LocationAnnotation : MKPointAnnotation

@property (nonatomic) Location *location;

@end
