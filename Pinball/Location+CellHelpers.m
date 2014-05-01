//
//  Location+CellHelpers.m
//  Pinball
//
//  Created by Frank Michael on 5/1/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location+CellHelpers.h"

@implementation Location (CellHelpers)

- (NSString *)fullAddress{
    return [NSString stringWithFormat:@"%@, %@, %@",self.street,self.city,self.state];
}

@end
