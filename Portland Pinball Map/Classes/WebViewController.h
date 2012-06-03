@interface WebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webview;
	NSString *theNewURL;
}

@property (nonatomic,strong) NSString *theNewURL;
@property (nonatomic,strong) IBOutlet UIWebView *webview;

- (IBAction)onBackTap:(id)sender;
- (IBAction)onForwardTap:(id)sender;

@end