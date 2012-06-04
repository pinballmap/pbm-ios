#import "BlackTableViewController.h"
#import "RequestPage.h"

@interface RegionSelectViewController : BlackTableViewController {
	NSArray *regionArray;
	RequestPage *requestPage;
}

@property (nonatomic,strong) RequestPage *requestPage;
@property (nonatomic,strong) NSArray *regionArray;

@end