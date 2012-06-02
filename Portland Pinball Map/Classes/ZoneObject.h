#import <Foundation/Foundation.h>

@interface ZoneObject : NSObject {
	NSString *name;
	NSString *id_number;
	NSString *shortName;
	NSString *isPrimary;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *id_number;
@property (nonatomic,retain) NSString *shortName;
@property (nonatomic,retain) NSString *isPrimary;

@end