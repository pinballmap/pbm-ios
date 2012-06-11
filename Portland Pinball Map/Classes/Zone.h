#import <Foundation/Foundation.h>

@interface Zone : NSObject {
	NSString *name;
	NSString *idNumber;
	NSString *shortName;
	NSString *isPrimary;
}

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *idNumber;
@property (nonatomic,strong) NSString *shortName;
@property (nonatomic,strong) NSString *isPrimary;

@end