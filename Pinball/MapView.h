//
//  LocationMapView.h
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Machine.h"

@interface MapView : UIViewController

@property (nonatomic)Location *currentLocation;
@property (nonatomic)Machine *currentMachine;

@end
