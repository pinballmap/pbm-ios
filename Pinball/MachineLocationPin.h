//
//  MachineLocationPin.h
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MachineLocationPin : MKPointAnnotation

@property (nonatomic) MachineLocation *currentMachine;

@end
