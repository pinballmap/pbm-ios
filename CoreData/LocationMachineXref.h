#import <Foundation/Foundation.h>

@class Location, Machine, RecentAddition;

@interface LocationMachineXref : NSManagedObject

@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSDate *conditionDate;
@property (nonatomic, strong) NSDate *dateAdded;
@property (nonatomic, strong) NSNumber *idNumber;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) Machine *machine;

+ (LocationMachineXref *)findForMachine:(Machine *)machine andLocation:(Location *)location;
+ (NSMutableArray *)locationsForMachine:(Machine *)machine;

@end