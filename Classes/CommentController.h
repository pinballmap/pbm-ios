#import "LocationMachineXref.h"
#import "PBMViewController.h"

@interface CommentController : PBMViewController <UITextViewDelegate,UIAlertViewDelegate> {
	UIButton *submitButton;
	UIButton *cancelButton;
	UITextView *textview;
	
	NSString *savedConditionText;
	
	LocationMachineXref *locationMachineXref;
}

@property (nonatomic,strong) LocationMachineXref *locationMachineXref;
@property (nonatomic,strong) IBOutlet UIButton *submitButton;
@property (nonatomic,strong) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) IBOutlet UITextView *textview;

- (IBAction)onSubmitTap:(id)sender;
- (IBAction)onCancelTap:(id)sender;

@end