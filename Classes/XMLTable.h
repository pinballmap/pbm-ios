#import "BlackTableViewController.h"
#import "Region.h"

@interface XMLTable : BlackTableViewController {
	BOOL isParsing;
	NSString *currentElement;
	
	UIView *loadingPage;
	UITableView *tableView2;
	
	UIActivityIndicatorView *indicator;
}

@property (nonatomic,strong) Region *region;

@property (nonatomic,assign) BOOL isParsing;
@property (nonatomic,strong) IBOutlet UIView *loadingPage;
@property (nonatomic,strong) IBOutlet UIView *tableView2;

-(id)initWithRegion:(Region*)activeRegion;

- (void)parseXMLFileAtURL:(NSString *)url;

@end