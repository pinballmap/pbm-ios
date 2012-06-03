#import "LocationObject.h"
#import "MachineObject.h"
#import "MachineFilterView.h"
#import "CommentController.h"
#import "WebViewController.h"

@interface MachineProfileViewController : UIViewController <UIActionSheetDelegate,UIAlertViewDelegate> {
	UILabel *machineLabel;
	UILabel *locationLabel;
	UILabel *conditionLabel;
	UITextView *conditionField;
	
	UIButton *returnButton;
	UIButton *deleteButton;
	UIButton *ipdbButton;
	UIButton *otherLocationsButton;
	UIButton *updateConditionButton;
	
	MachineFilterView *machineFilter;
	
	WebViewController *webview;
	
	CommentController *commentController;
	
	LocationObject *location;
	MachineObject  *machine;
}

@property (nonatomic,strong) WebViewController *webview;
@property (nonatomic,strong) LocationObject *location;
@property (nonatomic,strong) MachineObject *machine;

@property (nonatomic,strong) CommentController *commentController;
@property (nonatomic,strong) MachineFilterView *machineFilter;

@property (nonatomic,strong) IBOutlet UIButton *updateConditionButton;
@property (nonatomic,strong) IBOutlet UIButton *otherLocationsButton;
@property (nonatomic,strong) IBOutlet UILabel *machineLabel;
@property (nonatomic,strong) IBOutlet UILabel *locationLabel;
@property (nonatomic,strong) IBOutlet UILabel *conditionLabel;
@property (nonatomic,strong) IBOutlet UITextView *conditionField;
@property (nonatomic,strong) IBOutlet UIButton *returnButton;
@property (nonatomic,strong) IBOutlet UIButton *ipdbButton;
@property (nonatomic,strong) IBOutlet UIButton *deleteButton;

- (IBAction)onUpdateConditionTap:(id)sender;
- (IBAction)onDeleteTap:(id)sender;
- (IBAction)onReturnTap:(id)sender;
- (IBAction)onIPDBTap:(id)sender;
- (IBAction)onOtherLocationsTap:(id)sender;
- (IBAction) onEditButtonPressed:(id)sender;
- (void)hideControllButtons:(BOOL)doHide;
- (void)removeMachineWithURL:(NSString *)urlstr;

+ (NSString *)urlEncodeValue:(NSString *)url;

@end