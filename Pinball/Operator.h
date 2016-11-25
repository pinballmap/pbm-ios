#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Region;

@interface Operator : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * operatorId;
@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) NSSet * locations;
@property (nonatomic, retain) Region * region;

@end

@interface Operator (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(Location *)value;
- (void)removeLocationsObject:(Location *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
