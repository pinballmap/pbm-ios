#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserProfileEditedLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) Region * region;
@property (nonatomic, retain) Location * location;


@end
