#import "XMLTable.h"
#import "PPMTableCell.h"
#import "LocationProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "EventObject.h"
#import "EventProfileViewController.h"

@interface EventsViewController : XMLTable {
	EventObject *eventObject;
	EventProfileViewController *eventProfile;
	
	UILabel *noEventsLabel;
	
	NSArray *weekdayTitles;
	
	NSMutableString *current_id;
	NSMutableString *current_name;
	NSMutableString *current_longDesc;
	NSMutableString *current_link;
	NSMutableString *current_categoryNo;
	NSMutableString *current_startDate;
	NSMutableString *current_endDate;
	NSMutableString *current_locationNo;
	
	NSRange dayRange;
	NSRange monthRange;
	NSRange yearRange;
	
	NSMutableArray *sectionArray;
	NSMutableArray *sectionTitles;
	
	NSDate *today;
	
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

@property (nonatomic,strong) UILabel        *noEventsLabel;
@property (nonatomic,strong) NSArray		*weekdayTitles;
@property (nonatomic,strong) NSDate         *today;
@property (nonatomic,strong) NSMutableArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *sectionTitles;
@property (nonatomic,strong) EventProfileViewController *eventProfile;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;
- (NSString *)formatDate:(NSString *)dateString;
- (NSDate *)getDateFromString:(NSString *)dateString;

@end