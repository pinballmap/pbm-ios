#import "PBMViewController.h"
#import "WebViewController.h"

@interface AboutViewController : PBMViewController {
	UIButton *drewButton;
	UIButton *ryanButton;
	UIButton *scottButton;
	UIButton *isaacButton;
	UIButton *ppmButton;
	
	WebViewController *webview;
}

@property (nonatomic,strong) WebViewController *webview;
@property (nonatomic,strong) IBOutlet UIButton *ppmButton;
@property (nonatomic,strong) IBOutlet UIButton *drewButton;
@property (nonatomic,strong) IBOutlet UIButton *ryanButton;
@property (nonatomic,strong) IBOutlet UIButton *scottButton;
@property (nonatomic,strong) IBOutlet UIButton *isaacButton;

- (IBAction)ppmButtonPress:(id)sender;
- (IBAction)drewButtonPress:(id)sender;
- (IBAction)ryanButtonPress:(id)sender;
- (IBAction)scottButtonPress:(id)sender;
- (IBAction)isaacButtonPress:(id)sender;
- (void)viewURL:(NSString *)url withTitle:(NSString *)title;

@end