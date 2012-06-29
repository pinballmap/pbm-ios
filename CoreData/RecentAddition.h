@class Location, Machine, Region;

@interface RecentAddition : NSManagedObject

@property (nonatomic, strong) NSDate *dateAdded;
@property (nonatomic, strong) Region *region;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) Machine *machine;

+ (RecentAddition *)findForLocation:(Location *)location andMachine:(Machine *)machine;

@end