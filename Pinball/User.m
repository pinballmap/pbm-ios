#import "User.h"

@implementation User

@dynamic userId, username, email, token;

+(NSString *)guestUsername { return @"GUEST_USERNAME"; }

@end
