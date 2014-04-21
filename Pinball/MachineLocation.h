//
//  MachineLocation.h
//  Pinball
//
//  Created by Frank Michael on 4/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Machine;

@interface MachineLocation : NSManagedObject

@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSDate * conditionUpdate;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Machine *machine;

@end
