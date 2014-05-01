//
//  Location+CellHelpers.h
//  Pinball
//
//  Created by Frank Michael on 5/1/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location.h"

@interface Location (CellHelpers)

- (NSString *)fullAddress;
- (void)saveMapShot:(UIImage *)snapshot;
- (UIImage *)mapShot;
@end
