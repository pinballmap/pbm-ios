#import <CoreLocation/CoreLocation.h>

@class Event, LocationMachineXref, RecentAddition, Region, Zone;

@interface Location : NSManagedObject {
    double distance;
}

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * idNumber;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * street1;
@property (nonatomic, retain) NSString * street2;
@property (nonatomic, retain) NSNumber * totalMachines;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *locationMachineXrefs;
@property (nonatomic, retain) Zone *locationZone;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) NSSet *recentAdditions;
@property (nonatomic) double distance;

- (void)updateDistance;
- (CLLocation *)coordinates;
- (NSString *)formattedDistance;

@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addLocationMachineXrefsObject:(LocationMachineXref *)value;
- (void)removeLocationMachineXrefsObject:(LocationMachineXref *)value;
- (void)addLocationMachineXrefs:(NSSet *)values;
- (void)removeLocationMachineXrefs:(NSSet *)values;

- (void)addRecentAdditionsObject:(RecentAddition *)value;
- (void)removeRecentAdditionsObject:(RecentAddition *)value;
- (void)addRecentAdditions:(NSSet *)values;
- (void)removeRecentAdditions:(NSSet *)values;
- (bool)isLoaded;

- (NSArray *)sortedLocationMachineXrefs;

@end