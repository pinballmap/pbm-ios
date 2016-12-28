#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserProfileHighScore : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * score;
@property (nonatomic, retain) NSString * machineName;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) User *user;


@end
