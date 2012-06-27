#import "PBMViewController.h"
#import "Location.h"

@interface AddMachineViewController : PBMViewController <UIPickerViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate> {
	UITextField *textfield;
	UIPickerView *picker;
	UIButton *submitButton;
	UIButton *returnButton;
	
	UIActivityIndicatorView *loaderIcon;
	
	Location *location;
    NSString *selectedMachineID;
}

@property (nonatomic,strong) Location *location;
@property (nonatomic,strong) NSString *selectedMachineID;

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *loaderIcon;
@property (nonatomic,strong) IBOutlet UIButton *submitButton;
@property (nonatomic,strong) IBOutlet UIButton *returnButton;
@property (nonatomic,strong) IBOutlet UITextField *textfield;
@property (nonatomic,strong) IBOutlet UIPickerView *picker;

- (IBAction)onReturnTap:(id)sender;
- (IBAction)onSumbitTap:(id)sender;
- (void)addMachineFromTextfield;
- (void)addMachineWithURL:(NSString *)urlstr;

@end