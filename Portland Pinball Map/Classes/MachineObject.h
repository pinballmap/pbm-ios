#import <Foundation/Foundation.h>

@interface MachineObject : NSObject {
	NSString *name;
	NSString *id_number;
	NSString *condition;
	NSString *condition_date;
	NSString *dateAdded;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *id_number;
@property (nonatomic,retain) NSString *condition;
@property (nonatomic,retain) NSString *condition_date;
@property (nonatomic,retain) NSString *dateAdded;

@end