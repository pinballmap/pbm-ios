#import "LocationObject.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "PPMTableCell.h"
#import "PPMDoubleTableCell.h"
#import "LocationProfileCell.h"

@interface BlackTableViewController : UITableViewController <NSXMLParserDelegate> {
	UIActivityIndicatorView *activityView;
	UILabel *loadingLabel;
	NSInteger headerHeight;
}

@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@property (nonatomic,strong) UILabel *loadingLabel;
@property (nonatomic,assign) NSInteger headerHeight;

NSInteger sortOnDistance(id obj1, id obj2, void *context);
NSInteger sortOnName(LocationObject *obj1, LocationObject *obj2, void *context);

- (void)showLoaderIcon;
- (void)hideLoaderIcon;
- (void)showLoaderIconLarge;
- (void)hideLoaderIconLarge;
- (void)refreshPage;
- (PPMTableCell *)getTableCell;
- (PPMDoubleTableCell *)getDoubleCell;
- (void)showLocationProfile:(LocationObject *)location withMapButton:(BOOL)showMapButton;
- (LocationProfileViewController *) getLocationProfile;

@end