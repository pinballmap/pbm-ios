#import "EventProfileViewController.h"
#import "EventObject.h"
#import "WebViewController.h"
#import "LocationProfileViewController.h"

@interface EventProfileViewController : UIViewController {	
	EventObject *eventObject;
	WebViewController *webview;
	
	UILabel *nameLabel;
	UILabel *locationLabel;
	UILabel *timeLabel;
	UIButton *webButton;
	UIButton *locationButton;
	UITextView *descText;
}

@property (nonatomic,retain) WebViewController *webview;
@property (nonatomic,retain) EventObject *eventObject;
@property (nonatomic,retain) IBOutlet UITextView *descText;
@property (nonatomic,retain) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) IBOutlet UILabel *locationLabel;
@property (nonatomic,retain) IBOutlet UILabel *timeLabel;
@property (nonatomic,retain) IBOutlet UIButton *webButton;
@property (nonatomic,retain) IBOutlet UIButton *locationButton;

- (IBAction)onLocationTap:(id)sender;
- (IBAction)onWebTap:(id)sender;

@end