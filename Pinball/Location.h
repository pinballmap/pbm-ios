//
//  Location.h
//  Pinball
//
//  Created by Frank Michael on 5/8/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, MachineLocation, Region;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSNumber * locationDistance;
@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) NSString * locationZone;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * machineCount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * neighborhood;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSNumber * zoneNo;
@property (nonatomic, retain) NSOrderedSet *events;
@property (nonatomic, retain) NSSet *machines;
@property (nonatomic, retain) Region *region;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)insertObject:(Event *)value inEventsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEventsAtIndex:(NSUInteger)idx;
- (void)insertEvents:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEventsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEventsAtIndex:(NSUInteger)idx withObject:(Event *)value;
- (void)replaceEventsAtIndexes:(NSIndexSet *)indexes withEvents:(NSArray *)values;
- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSOrderedSet *)values;
- (void)removeEvents:(NSOrderedSet *)values;
- (void)addMachinesObject:(MachineLocation *)value;
- (void)removeMachinesObject:(MachineLocation *)value;
- (void)addMachines:(NSSet *)values;
- (void)removeMachines:(NSSet *)values;

@end
