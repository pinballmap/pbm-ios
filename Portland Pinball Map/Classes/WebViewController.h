@interface WebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webview;
	NSString  *newURL;
}

@property (nonatomic,retain) NSString *newURL;
@property (nonatomic,retain) IBOutlet UIWebView *webview;

- (IBAction)onBackTap:(id)sender;
- (IBAction)onForwardTap:(id)sender;

@end