#import "XMLTable.h"
#import "LocationProfileViewController.h"
#import "Event.h"
#import "EventProfileViewController.h"

@interface EventsViewController : XMLTable {
	Event *eventObject;
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
		
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

@property (nonatomic,strong) UILabel *noEventsLabel;
@property (nonatomic,strong) NSArray *weekdayTitles;
@property (nonatomic,strong) NSMutableArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *sectionTitles;
@property (nonatomic,strong) EventProfileViewController *eventProfile;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;

@end