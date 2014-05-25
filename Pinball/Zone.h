//
//  Zone.h
//  Pinball
//
//  Created by Frank Michael on 5/25/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Region;

@interface Zone : NSManagedObject

@property (nonatomic, retain) NSNumber * zoneId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) NSSet *locations;
@end

@interface Zone (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(Location *)value;
- (void)removeLocationsObject:(Location *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
