#import "XMLTable.h"
#import "PPMDoubleTableCell.h"
#import "LocationProfileViewController.h"

@interface RSSViewController : XMLTable {
	NSMutableDictionary *item;
	NSMutableString *currentTitle;
	NSMutableString *currentDesc;
		
	NSRange dayRange;
	NSRange monthRange;
	NSRange yearRange;
	
	NSMutableArray *sectionArray;
	NSMutableArray *sectionTitles;
	
	NSDate *today;
	
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

@property (nonatomic,strong) NSDate *today;
@property (nonatomic,strong) NSMutableArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *sectionTitles;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;

@end