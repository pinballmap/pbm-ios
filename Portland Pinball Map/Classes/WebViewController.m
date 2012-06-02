#import "WebViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation WebViewController
@synthesize webview, newURL;

- (void)viewDidLoad {	
	webview.delegate = self;
	webview.scalesPageToFit = YES;
	
	NSURL *url = [NSURL URLWithString:@"http://ipdb.org"];
	
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	[webview loadRequest:requestObj];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSString *urlAddress = newURL;
	
	NSURL *url = [NSURL URLWithString:urlAddress];	
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	[webview loadRequest:requestObj];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[webview stopLoading];
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	self.webview = nil;
}

- (IBAction)onBackTap:(id)sender {
	if(webview.canGoBack)
        [webview goBack];
}

- (IBAction)onForwardTap:(id)sender
{
	if(webview.canGoForward)
        [webview goForward];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
}

- (void)dealloc {
	[newURL release];
	[webview release];
    [super dealloc];
}

@end