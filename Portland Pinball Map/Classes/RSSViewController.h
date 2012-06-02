#import "XMLTable.h"
#import "PPMTableCell.h"
#import "LocationProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@interface RSSViewController : XMLTable {
	NSMutableDictionary * item;
	NSMutableString * currentTitle;
	NSMutableString * currentDesc;
		
	NSRange dayRange;
	NSRange monthRange;
	NSRange yearRange;
	
	NSMutableArray *sectionArray;
	NSMutableArray *sectionTitles;
	
	NSDate *today;
	
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

@property (nonatomic,retain) NSDate         *today;
@property (nonatomic,retain) NSMutableArray *sectionArray;
@property (nonatomic,retain) NSMutableArray *sectionTitles;

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;

@end