#import <Foundation/Foundation.h>

@interface MachineObject : NSObject {
	NSString *name;
	NSString *idNumber;
	NSString *condition;
	NSString *conditionDate;
	NSString *dateAdded;
}

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *idNumber;
@property (nonatomic,strong) NSString *condition;
@property (nonatomic,strong) NSString *conditionDate;
@property (nonatomic,strong) NSString *dateAdded;

@end