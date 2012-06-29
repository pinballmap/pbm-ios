#import "XMLTable.h"

#define ONE_YEAR 365
#define ONE_MONTH 31
#define ONE_WEEK 7
#define ONE_DAY 1
#define DISTANT_FUTURE 2000
#define TODAY @"today"
#define YESTERDAY @"yesterday"
#define THIS_WEEK @"this week"
#define THIS_MONTH @"this month"
#define THIS_YEAR @"this year"

@interface RecentlyAddedViewController : XMLTable {
	NSMutableString *currentTitle;
	NSMutableString *currentDesc;
		
    NSMutableDictionary *sectionData;
    
	BOOL parsingItemNode;	
}

@property (nonatomic,strong) NSMutableDictionary *sectionData;

@end