#import <Foundation/Foundation.h>

@interface MachineObject : NSObject {
	NSString *name;
	NSString *id_number;
	NSString *condition;
	NSString *condition_date;
	NSString *dateAdded;
}

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *id_number;
@property (nonatomic,strong) NSString *condition;
@property (nonatomic,strong) NSString *condition_date;
@property (nonatomic,strong) NSString *dateAdded;

@end