#import "User.h"

@interface User (Create)

+ (instancetype)createUserWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context;

@end
