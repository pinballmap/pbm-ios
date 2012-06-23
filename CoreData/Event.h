#import <Foundation/Foundation.h>

@class Location, Region;

@interface Event : NSManagedObject

@property (nonatomic,strong) NSNumber *categoryNo;
@property (nonatomic,strong) NSDate *endDate;
@property (nonatomic,strong) NSString *externalLink;
@property (nonatomic,strong) NSString *longDesc;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSDate *startDate;
@property (nonatomic,strong) Location *location;
@property (nonatomic,strong) Region *region;

@end