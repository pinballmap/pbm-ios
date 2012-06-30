#import "XMLTable.h"
#import "LocationProfileViewController.h"
#import "Event.h"

#define FEATURED @"featured"
#define TOURNAMENTS @"tournaments"
#define OTHER @"other"
#define PAST_EVENTS @"past events"

@interface EventsViewController : XMLTable {	
    NSNumber *currentID;
    NSNumber *currentCategoryNo;
    NSNumber *currentLocationID;
    NSMutableString *currentName;
	NSMutableString *currentLongDesc;
	NSMutableString *currentLink;
	NSDate *currentStartDate;
	NSDate *currentEndDate;
	
    NSMutableDictionary *sectionData;
		
	BOOL parsingItemNode;	
}

@property (nonatomic,strong) NSMutableDictionary *sectionData;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;

@end