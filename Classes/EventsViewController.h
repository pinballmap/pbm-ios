#import "XMLTable.h"
#import "LocationProfileViewController.h"
#import "Event.h"
#import "EventProfileViewController.h"

@interface EventsViewController : XMLTable {
	EventProfileViewController *eventProfileViewController;
	
	UILabel *noEventsLabel;
	
	NSArray *weekdayTitles;
	
    NSNumber *currentID;
    NSNumber *currentCategoryNo;
    NSNumber *currentLocationID;
    NSMutableString *currentName;
	NSMutableString *currentLongDesc;
	NSMutableString *currentLink;
	NSDate *currentStartDate;
	NSDate *currentEndDate;
	
	NSMutableArray *sectionArray;
	NSMutableArray *sectionTitles;
		
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

@property (nonatomic,strong) UILabel *noEventsLabel;
@property (nonatomic,strong) NSArray *weekdayTitles;
@property (nonatomic,strong) NSMutableArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *sectionTitles;
@property (nonatomic,strong) EventProfileViewController *eventProfileViewController;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;

@end