#import "XMLTable.h"
#import "LocationProfileViewController.h"

#define ONE_YEAR 365
#define ONE_MONTH 31
#define ONE_WEEK 7
#define ONE_DAY 1
#define DISTANT_FUTURE 2000

@interface RecentlyAddedViewController : XMLTable {
	NSMutableDictionary *newMachineAtLocation;
	NSMutableString *currentTitle;
	NSMutableString *currentDesc;
		
	NSMutableArray *sectionData;
	NSMutableArray *sectionTitles;
    
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

@property (nonatomic,strong) NSMutableArray *sectionData;
@property (nonatomic,strong) NSMutableArray *sectionTitles;

@end