@interface RequestPage : UIViewController {
	UIButton *contactButton;
}

@property (nonatomic,strong) IBOutlet UIButton *contactButton;

- (IBAction)onContactTap:(id)sender;

@end