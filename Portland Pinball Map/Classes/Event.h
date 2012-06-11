#import "Location.h"

@interface Event : NSObject {
	NSString *idNumber;
	NSString *name;
	NSString *longDesc;
	NSString *link;
	NSString *categoryNo;
	NSString *startDate;
	NSString *endDate;
	NSString *locationNo;
	NSString *displayDate;
	NSString *displayName;
    
    Location *location;
}

@property (nonatomic,strong) NSString *idNumber;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *longDesc;
@property (nonatomic,strong) NSString *link;
@property (nonatomic,strong) NSString *categoryNo;
@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;
@property (nonatomic,strong) NSString *locationNo;
@property (nonatomic,strong) NSString *displayDate;
@property (nonatomic,strong) NSString *displayName;

@property (nonatomic,strong) Location *location;

@end