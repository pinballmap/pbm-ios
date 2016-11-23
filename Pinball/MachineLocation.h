//
//  MachineLocation.h
//  PinballMap
//
//  Created by Frank Michael on 5/18/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Machine, MachineCondition;

@interface MachineLocation : NSManagedObject

@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSDate * conditionUpdate;
@property (nonatomic, retain) NSNumber * machineLocationId;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Machine *machine;
@property (nonatomic, retain) NSSet * conditions;
@property (nonatomic, retain) NSString * updatedByUsername;

@end

@interface MachineLocation (CoreDataGeneratedAccessors)

- (void)addConditionsObject:(MachineCondition *)value;

@end
