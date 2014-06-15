//
//  Machine.h
//  PinballMap
//
//  Created by Frank Michael on 5/10/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MachineLocation;

@interface Machine : NSManagedObject

@property (nonatomic, retain) NSNumber * machineId;
@property (nonatomic, retain) NSString * manufacturer;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * ipdbLink;
@property (nonatomic, retain) NSOrderedSet *machineLocations;
@end

@interface Machine (CoreDataGeneratedAccessors)

- (void)insertObject:(MachineLocation *)value inMachineLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMachineLocationsAtIndex:(NSUInteger)idx;
- (void)insertMachineLocations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMachineLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMachineLocationsAtIndex:(NSUInteger)idx withObject:(MachineLocation *)value;
- (void)replaceMachineLocationsAtIndexes:(NSIndexSet *)indexes withMachineLocations:(NSArray *)values;
- (void)addMachineLocationsObject:(MachineLocation *)value;
- (void)removeMachineLocationsObject:(MachineLocation *)value;
- (void)addMachineLocations:(NSOrderedSet *)values;
- (void)removeMachineLocations:(NSOrderedSet *)values;
@end
