#import "BlackTableViewController.h"
#import "RequestPage.h"

@interface RegionSelectViewController : BlackTableViewController {
	NSArray *regionArray;
	RequestPage *requestPage;
}

@property (nonatomic,retain) RequestPage *requestPage;
@property (nonatomic,retain) NSArray *regionArray;

@end