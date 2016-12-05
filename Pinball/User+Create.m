#import "User+Create.h"

@implementation User (Create)

+ (instancetype)createUserWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    
    User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    newUser.userId = data[@"id"];
    newUser.username = data[@"username"];
    newUser.email = data[@"email"];
    newUser.token = data[@"authentication_token"];
        
    return newUser;
}

@end
