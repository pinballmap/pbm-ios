#import "EventProfileViewController.h"
#import "Event.h"
#import "WebViewController.h"
#import "PBMViewController.h"
#import "LocationProfileViewController.h"

@interface EventProfileViewController : PBMViewController {	
	Event *event;
	WebViewController *webview;
	
	UILabel *nameLabel;
	UILabel *locationLabel;
	UILabel *timeLabel;
	UIButton *webButton;
	UIButton *locationButton;
	UITextView *descText;
}

@property (nonatomic,strong) WebViewController *webview;
@property (nonatomic,strong) Event *event;
@property (nonatomic,strong) IBOutlet UITextView *descText;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *locationLabel;
@property (nonatomic,strong) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) IBOutlet UIButton *webButton;
@property (nonatomic,strong) IBOutlet UIButton *locationButton;

- (IBAction)onLocationTap:(id)sender;
- (IBAction)onWebTap:(id)sender;

@end