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

@property (nonatomic,strong) WebViewController *webview;
@property (nonatomic,strong) EventObject *eventObject;
@property (nonatomic,strong) IBOutlet UITextView *descText;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *locationLabel;
@property (nonatomic,strong) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) IBOutlet UIButton *webButton;
@property (nonatomic,strong) IBOutlet UIButton *locationButton;

- (IBAction)onLocationTap:(id)sender;
- (IBAction)onWebTap:(id)sender;

@end