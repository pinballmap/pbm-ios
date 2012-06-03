#import <Foundation/Foundation.h>
#import "LocationObject.h"

@interface EventObject : NSObject {
	NSString *id_number;
	NSString *name;
	NSString *longDesc;
	NSString *link;
	NSString *categoryNo;
	NSString *startDate;
	NSString *endDate;
	NSString *locationNo;
	NSString *displayDate;
	NSString *displayName;
    
    LocationObject *location;
}

@property (nonatomic,strong) NSString *id_number;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *longDesc;
@property (nonatomic,strong) NSString *link;
@property (nonatomic,strong) NSString *categoryNo;
@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;
@property (nonatomic,strong) NSString *locationNo;
@property (nonatomic,strong) NSString *displayDate;
@property (nonatomic,strong) NSString *displayName;

@property (nonatomic,strong) LocationObject *location;


@end