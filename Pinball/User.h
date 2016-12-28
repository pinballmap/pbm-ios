#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * token;

@property (nonatomic, retain) NSString * numMachinesAdded;
@property (nonatomic, retain) NSString * numMachinesRemoved;
@property (nonatomic, retain) NSString * numLocationsEdited;
@property (nonatomic, retain) NSString * numLocationsSuggested;
@property (nonatomic, retain) NSString * numCommentsLeft;
@property (nonatomic, retain) NSDate * dateCreated;

@property (nonatomic, retain) NSSet *userProfileEditedLocations;
@property (nonatomic, retain) NSSet *userProfileHighScores;

+(NSString *)guestUsername;
-(Boolean)isGuest;

@end
