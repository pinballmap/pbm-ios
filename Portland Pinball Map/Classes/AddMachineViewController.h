@class LocationObject;

@interface AddMachineViewController : UIViewController <UIPickerViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate> {
	UITextField *textfield;
	UIPickerView *picker;
	UIButton *submitButton;
	UIButton *returnButton;
	NSMutableArray *machineArray;
	
	UIActivityIndicatorView *loaderIcon;
	
	LocationObject *location;
	NSString *locationName;
	NSString *locationId;
    NSString *selected_machine_id;
}

@property (nonatomic,strong) LocationObject *location;
@property (nonatomic,strong) NSString *selected_machine_id;
@property (nonatomic,strong) NSString *locationName;
@property (nonatomic,strong) NSString *locationId;

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *loaderIcon;
@property (nonatomic,strong) IBOutlet UIButton *submitButton;
@property (nonatomic,strong) IBOutlet UIButton *returnButton;
@property (nonatomic,strong) IBOutlet UITextField *textfield;
@property (nonatomic,strong) IBOutlet UIPickerView *picker;

- (IBAction)onReturnTap:(id)sender;
- (IBAction)onSumbitTap:(id)sender;
- (void)addMachineFromTextfield;
- (void)addMachineWithURL:(NSString *)urlstr;
- (NSString *)stripString:(NSString *)string;

@end