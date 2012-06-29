@class LocationMachineXref, RecentAddition, Region;

@interface Machine : NSManagedObject

@property (nonatomic, strong) NSNumber *idNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet *locationMachineXref;
@property (nonatomic, strong) NSSet *region;
@property (nonatomic, strong) NSSet *recentAdditions;
@end

@interface Machine (CoreDataGeneratedAccessors)

- (void)addLocationMachineXrefObject:(LocationMachineXref *)value;
- (void)removeLocationMachineXrefObject:(LocationMachineXref *)value;
- (void)addLocationMachineXref:(NSSet *)values;
- (void)removeLocationMachineXref:(NSSet *)values;

- (void)addRegionObject:(Region *)value;
- (void)removeRegionObject:(Region *)value;
- (void)addRegion:(NSSet *)values;
- (void)removeRegion:(NSSet *)values;

- (void)addRecentAdditionsObject:(RecentAddition *)value;
- (void)removeRecentAdditionsObject:(RecentAddition *)value;
- (void)addRecentAdditions:(NSSet *)values;
- (void)removeRecentAdditions:(NSSet *)values;

@end