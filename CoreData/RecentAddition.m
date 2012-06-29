#import "RecentAddition.h"
#import "Location.h"
#import "Machine.h"
#import "Region.h"

@implementation RecentAddition

@dynamic dateAdded, region, location, machine;

+ (RecentAddition *)findForLocation:(Location *)location andMachine:(Machine *)machine {
    for (RecentAddition *recentAddition in location.recentAdditions) {
        if ([machine.idNumber isEqualToNumber:recentAddition.machine.idNumber]) {
            return recentAddition;
        }
    }
    
    return nil;
}

@end