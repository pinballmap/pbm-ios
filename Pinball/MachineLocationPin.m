//
//  MachineLocationPin.m
//  PinballMap
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineLocationPin.h"

@implementation MachineLocationPin

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@ %p> %@",self.class,self,_currentMachine];
}

@end
