@interface RequestPage : UIViewController {
	UIButton *contactButton;
}

@property (nonatomic,retain) IBOutlet UIButton *contactButton;

- (IBAction)onContactTap:(id)sender;

@end