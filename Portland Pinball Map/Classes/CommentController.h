#import "MachineObject.h"
#import "LocationObject.h"

@interface CommentController : UIViewController <UITextViewDelegate,UIAlertViewDelegate> {
	UIButton *submitButton;
	UIButton *cancelButton;
	UITextView *textview;
	
	NSString *savedConditionText;
	
	MachineObject *machine;
	LocationObject *location;
}

@property (nonatomic,strong) LocationObject *location;
@property (nonatomic,strong) MachineObject *machine;
@property (nonatomic,strong) IBOutlet UIButton *submitButton;
@property (nonatomic,strong) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) IBOutlet UITextView *textview;

- (IBAction)onSubmitTap:(id)sender;
- (IBAction)onCancelTap:(id)sender;

@end