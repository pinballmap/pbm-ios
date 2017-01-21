#import "LoginViewController.h"
#import "AppDelegate.h"
#import "PinballMapManager.h"
#import "UIAlertView+Application.h"
#import "RegionsView.h"
#import "LoadingViewController.h"
#import "NSDate+DateFormatting.h"

@interface LoginViewController ()
@property (weak) IBOutlet UITextField *loginField;
@property (weak) IBOutlet UITextField *passwordField;
@property (nonatomic) BOOL alreadyRefreshed;

@end

@implementation LoginViewController

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(50,0,0,0)];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/join",[PinballMapManager getApiRootURL]]]];
}

- (IBAction)continueAsGuest:(id)sender{
    NSDictionary *guestLoginData = @{
        @"id": [NSNumber numberWithInt:-1],
        @"username": [User guestUsername],
        @"email": @"GUEST@NOACCOUNT.EDU",
        @"numMachinesAdded": @"0",
        @"numMachinesRemoved" : @"0",
        @"numLocationsEdited" : @"0",
        @"numLocationsSuggested" : @"0",
        @"numCommentsLeft": @"0",
        @"createdAt": @"2008-12-07"
    };
    
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    User *user = [User createUserWithData:guestLoginData andContext:cdManager.managedObjectContext];
    [[PinballMapManager sharedInstance] loadUserData:user];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:nil];
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)attemptLogin:(id)sender{
    if (self.loginField.text.length == 0){
        [UIAlertView simpleApplicationAlertWithMessage:@"You must enter a login" cancelButton:@"Ok"];
        return;
    }else if (self.passwordField.text.length == 0){
        [UIAlertView simpleApplicationAlertWithMessage:@"You must enter a password" cancelButton:@"Ok"];
        return;
    }
    
    NSDictionary *loginData = @{
        @"login": self.loginField.text,
        @"password": self.passwordField.text,
    };
    
    [[PinballMapManager sharedInstance] login:loginData andCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            CoreDataManager *cdManager = [CoreDataManager sharedInstance];
            User *user = [User createUserWithData:status[@"user"] andContext:cdManager.managedObjectContext];
            [[PinballMapManager sharedInstance] loadUserData:user];

            [self dismissViewControllerAnimated:NO completion:^{}];
        }
    }];
}

@end
