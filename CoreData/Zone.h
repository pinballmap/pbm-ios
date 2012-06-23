#import <Foundation/Foundation.h>

@class Location, Region;

@interface Zone : NSManagedObject

@property (nonatomic,strong) NSNumber *idNumber;
@property (nonatomic,strong) NSNumber *isPrimary;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSSet *location;
@property (nonatomic,strong) Region *region;
@end

@interface Zone (CoreDataGeneratedAccessors)

- (void)addLocationObject:(Location *)value;
- (void)removeLocationObject:(Location *)value;
- (void)addLocation:(NSSet *)values;
- (void)removeLocation:(NSSet *)values;

@end
