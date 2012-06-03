#import <Foundation/Foundation.h>

@interface ZoneObject : NSObject {
	NSString *name;
	NSString *id_number;
	NSString *shortName;
	NSString *isPrimary;
}

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *id_number;
@property (nonatomic,strong) NSString *shortName;
@property (nonatomic,strong) NSString *isPrimary;

@end