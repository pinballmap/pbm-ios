//
//  UserLocationHelper.h
//  CoreLocationHelper
//
//  Created by Frank Michael on 3/2/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface UserLocationHelper : NSObject


typedef void (^LocationUpdated)(CLLocation *location);

- (void)getUserLocationWithCompletion:(LocationUpdated)block;

@end
