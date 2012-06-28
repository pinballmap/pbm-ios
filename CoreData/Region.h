#import <CoreLocation/CoreLocation.h>

@class Event, Location, Machine, RecentAddition, Zone;

@interface Region : NSManagedObject

@property (nonatomic, strong) NSString *formalName;
@property (nonatomic, strong) NSNumber *idNumber;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *nMachines;
@property (nonatomic, strong) NSString *subdir;
@property (nonatomic, strong) NSSet *events;
@property (nonatomic, strong) NSSet *locations;
@property (nonatomic, strong) NSSet *recentAdditions;
@property (nonatomic, strong) NSSet *zones;
@property (nonatomic, strong) NSSet *machines;

- (CLLocation *)coordinates;
- (NSString *)formattedNMachines;
- (NSArray *)primaryZones;
- (NSArray *)secondaryZones;

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

- (void)addRecentAdditionsObject:(RecentAddition *)value;
- (void)removeRecentAdditionsObject:(RecentAddition *)value;
- (void)addRecentAdditions:(NSSet *)values;
- (void)removeRecentAdditions:(NSSet *)values;

- (void)addZonesObject:(Zone *)value;
- (void)removeZonesObject:(Zone *)value;
- (void)addZones:(NSSet *)values;
- (void)removeZones:(NSSet *)values;

- (void)addMachinesObject:(Machine *)value;
- (void)removeMachinesObject:(Machine *)value;
- (void)addMachines:(NSSet *)values;
- (void)removeMachines:(NSSet *)values;

@end
