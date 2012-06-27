#import "PBMViewController.h"

@interface RequestPage : PBMViewController {
	UIButton *contactButton;
}

@property (nonatomic,strong) IBOutlet UIButton *contactButton;

- (IBAction)onContactTap:(id)sender;

@end