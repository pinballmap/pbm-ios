#import "User.h"

@implementation User

@dynamic userId, username, email, token, numMachinesAdded, numMachinesRemoved, numLocationsEdited, numLocationsSuggested, numCommentsLeft, createdAt;

+(NSString *)guestUsername { return @"GUEST_USERNAME"; }

-(Boolean)isGuest {
    return [self.username isEqualToString:[User guestUsername]];
}

@end
