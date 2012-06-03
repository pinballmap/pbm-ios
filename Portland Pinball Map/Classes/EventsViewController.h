#import "XMLTable.h"
#import "LocationProfileViewController.h"
#import "EventObject.h"
#import "EventProfileViewController.h"

@interface EventsViewController : XMLTable {
	EventObject *eventObject;
	EventProfileViewController *eventProfile;
	
	UILabel *noEventsLabel;
	
	NSArray *weekdayTitles;
	
	NSMutableString *currentID;
	NSMutableString *currentName;
	NSMutableString *currentLongDesc;
	NSMutableString *currentLink;
	NSMutableString *currentCategoryNo;
	NSMutableString *currentStartDate;
	NSMutableString *currentEndDate;
	NSMutableString *currentLocationNo;
	
	NSMutableArray *sectionArray;
	NSMutableArray *sectionTitles;
	
	NSDate *today;
	
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

@property (nonatomic,strong) UILabel *noEventsLabel;
@property (nonatomic,strong) NSArray *weekdayTitles;
@property (nonatomic,strong) NSDate *today;
@property (nonatomic,strong) NSMutableArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *sectionTitles;
@property (nonatomic,strong) EventProfileViewController *eventProfile;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;
- (NSDate *)getDateFromString:(NSString *)dateString;

@end