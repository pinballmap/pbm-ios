#import "WebViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation WebViewController
@synthesize webview, theNewURL;

- (void)viewDidLoad {	
	[webview setDelegate:self];
	[webview setScalesPageToFit:YES];
	
	NSURL *url = [NSURL URLWithString:@"http://ipdb.org"];
	[webview loadRequest:[NSURLRequest requestWithURL:url]];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:theNewURL]];
	
	[webview loadRequest:requestObj];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[webview stopLoading];
	
	UIApplication* app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:NO];
	
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	[self setWebview:nil];
}

- (IBAction)onBackTap:(id)sender {
	if(webview.canGoBack)
        [webview goBack];
}

- (IBAction)onForwardTap:(id)sender {
	if(webview.canGoForward)
        [webview goForward];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	UIApplication* app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	UIApplication* app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];
}

@end