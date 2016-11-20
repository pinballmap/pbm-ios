#import "ProfileView.h"
#import "LoginViewController.h"

@interface ProfileView ()

@end

@implementation ProfileView

@synthesize usernameLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    User *user = [[PinballMapManager sharedInstance] currentUser];
    self.usernameLabel.text = user.username;
    self.numCommentsLeftLabel.text = user.numCommentsLeft;
    self.numMachinesAddedLabel.text = user.numMachinesAdded;
    self.numLocationsEditedLabel.text = user.numLocationsEdited;
    self.numMachinesRemovedLabel.text = user.numMachinesRemoved;
    self.numLocationsSuggestedLabel.text = user.numLocationsSuggested;
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender {
    LoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
