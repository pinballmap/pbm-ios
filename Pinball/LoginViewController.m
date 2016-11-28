#import "LoginViewController.h"
#import "AppDelegate.h"
#import "PinballMapManager.h"
#import "UIAlertView+Application.h"
#import "RegionsView.h"
#import "LoadingViewController.h"

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

            user = [[PinballMapManager sharedInstance] currentUser];
            
            [[PinballMapManager sharedInstance] loadUserProfileData:user andCompletion:^(NSDictionary *status) {
                if (status[@"errors"]) {
                    NSString *errors;
                    if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                        errors = [status[@"errors"] componentsJoinedByString:@","];
                    }else{
                        errors = status[@"errors"];
                    }
                    [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
                } else {
                    /*
                    {"profile_info":{"id":78,"num_machines_added":11,"num_machines_removed":4,"num_locations_edited":25,"num_locations_suggested":2,"num_lmx_comments_left":9,"profile_list_of_edited_locations":[[2787,"Corrales Laundromat",21],[2788,"Launchpad",21],[2772,"Cinemark Movies West",21],[2360,"21st Avenue Bicycles",1],[1002,"45th Street Pub",1],[4715,"Alonso's",51],[888,"The Standard",1],[864,"Billy Ray's Neighborhood Dive",1],[941,"Bar of the Gods (BOG)",1],[2348,"Cinetopia Progress Ridge",1],[4000,"AMF Pro 300 Lanes",1],[4653,"3.99 Pizza Company",5],[1334,"AMF Mar Vista Lanes",5],[4502,"Alameda Coin Laundry",5],[3382,"Alex's Arcade",5],[3957,"Arlington Lanes",5],[2370,"Alpine Slide at Magic Mountain (Big Bear)",5],[1004,"52nd Avenue Sports Bar",1],[3628,"McMenamins Barley Mill Pub",1],[977,"Montavilla Station",1],[4282,"The Coin Jam",1],[4845,"Pins and Needles",5],[2834,"Golden Saddle Cyclery",5],[2290,"Eagle LA",5],[4465,"Game Over Arcade",1]],"profile_list_of_high_scores":[["45th Street Pub","AC/DC (LE)","62,000,500","Oct-11-2016"],["Pins and Needles","Black Knight 2000","12,584,600","Nov-19-2016"]],"created_at":"2016-08-13T21:41:07.291Z"}}*/
                    
                    user.numLocationsSuggested = [status[@"profile_info"][@"num_locations_suggested"] stringValue];
                    user.numMachinesRemoved = [status[@"profile_info"][@"num_machines_removed"] stringValue];
                    user.numLocationsEdited = [status[@"profile_info"][@"num_locations_edited"] stringValue];
                    user.numMachinesAdded = [status[@"profile_info"][@"num_machines_added"] stringValue];
                    user.numCommentsLeft = [status[@"profile_info"][@"num_lmx_comments_left"] stringValue];
                    
                    [[PinballMapManager sharedInstance] loadUserData:user];
                    
                    [self dismissViewControllerAnimated:NO completion:^{}];
                }
            }];
        }
    }];
}

@end
