#import <Foundation/Foundation.h>

@class LocationMachineXref, Region;

@interface RecentAddition : NSManagedObject

@property (nonatomic,strong) NSDate *dateAdded;
@property (nonatomic,strong) LocationMachineXref *locationMachineXref;
@property (nonatomic,strong) Region *region;

@end