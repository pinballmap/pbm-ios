#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Event, LocationMachineXref, Region, Zone;

@interface Location : NSManagedObject {
    double distance;
}

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSNumber *idNumber;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *street1;
@property (nonatomic, strong) NSString *street2;
@property (nonatomic, strong) NSNumber *totalMachines;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSSet *events;
@property (nonatomic, strong) NSSet *locationMachineXrefs;
@property (nonatomic, strong) Zone *locationZone;
@property (nonatomic, strong) Region *region;
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
- (bool)isLoaded;

@end
