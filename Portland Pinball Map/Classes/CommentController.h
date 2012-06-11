#import "Machine.h"
#import "Location.h"

@interface CommentController : UIViewController <UITextViewDelegate,UIAlertViewDelegate> {
	UIButton *submitButton;
	UIButton *cancelButton;
	UITextView *textview;
	
	NSString *savedConditionText;
	
	Machine *machine;
	Location *location;
}

@property (nonatomic,strong) Location *location;
@property (nonatomic,strong) Machine *machine;
@property (nonatomic,strong) IBOutlet UIButton *submitButton;
@property (nonatomic,strong) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) IBOutlet UITextView *textview;

- (IBAction)onSubmitTap:(id)sender;
- (IBAction)onCancelTap:(id)sender;

@end