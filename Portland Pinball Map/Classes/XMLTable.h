#import "BlackTableViewController.h"

@interface XMLTable : BlackTableViewController {
	BOOL isParsing;
	NSString *currentElement;
	
	UIView *loadingPage;
	UITableView *tableView2;
	
	UIActivityIndicatorView *indicator;
}

@property (nonatomic,assign) BOOL isParsing;
@property (nonatomic,strong) IBOutlet UIView *loadingPage;
@property (nonatomic,strong) IBOutlet UIView *tableView2;

- (void)parseXMLFileAtURL:(NSString *)url;

@end