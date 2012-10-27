#import "XMLTable.h"
#import "LocationProfileViewController.h"
#import "Event.h"

#define FEATURED @"featured"
#define TOURNAMENTS @"tournaments"
#define OTHER @"other"
#define PAST_EVENTS @"past events"

@interface EventsViewController : XMLTable {	
    NSMutableDictionary *sectionData;
}

@property (nonatomic,strong) NSMutableDictionary *sectionData;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;

@end