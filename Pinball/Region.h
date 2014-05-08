//
//  Region.h
//  Pinball
//
//  Created by Frank Michael on 5/8/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Location;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) NSString * locationsEtag;
@property (nonatomic, retain) NSString * eventsEtag;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *locations;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addLocationsObject:(Location *)value;
- (void)removeLocationsObject:(Location *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
