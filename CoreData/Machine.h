#import <Foundation/Foundation.h>

@class LocationMachineXref;

@interface Machine : NSManagedObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSNumber *idNumber;
@property (nonatomic,strong) NSSet *locationMachineXref;
@end

@interface Machine (CoreDataGeneratedAccessors)

- (void)addLocationMachineXrefObject:(LocationMachineXref *)value;
- (void)removeLocationMachineXrefObject:(LocationMachineXref *)value;
- (void)addLocationMachineXref:(NSSet *)values;
- (void)removeLocationMachineXref:(NSSet *)values;

@end