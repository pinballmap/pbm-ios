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

@property (nonatomic,retain) NSString *id_number;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *longDesc;
@property (nonatomic,retain) NSString *link;
@property (nonatomic,retain) NSString *categoryNo;
@property (nonatomic,retain) NSString *startDate;
@property (nonatomic,retain) NSString *endDate;
@property (nonatomic,retain) NSString *locationNo;
@property (nonatomic,retain) NSString *displayDate;
@property (nonatomic,retain) NSString *displayName;

@property (nonatomic,retain) LocationObject *location;


@end