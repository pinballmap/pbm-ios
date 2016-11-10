#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * token;

+(NSString *) guestUsername;

@end
