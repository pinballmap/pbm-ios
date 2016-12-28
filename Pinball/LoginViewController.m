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
            
            
            //###########################
            // HEY WE NEED TO HAVE THIS HAPPEN WHEN SOMEONE CHANGES REGIONS TOO!!!!!!!
            //###########################
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
                    user.numLocationsSuggested = [status[@"profile_info"][@"num_locations_suggested"] stringValue];
                    user.numMachinesRemoved = [status[@"profile_info"][@"num_machines_removed"] stringValue];
                    user.numLocationsEdited = [status[@"profile_info"][@"num_locations_edited"] stringValue];
                    user.numMachinesAdded = [status[@"profile_info"][@"num_machines_added"] stringValue];
                    user.numCommentsLeft = [status[@"profile_info"][@"num_lmx_comments_left"] stringValue];
                    
                    if (![status[@"profile_info"][@"created_at"] isKindOfClass:[NSNull class]]){
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"YYYY-MM-dd"];
                        
                        NSString *createdString = status[@"profile_info"][@"created_at"];
                        createdString = [createdString substringToIndex:[createdString rangeOfString:@"T"].location];
                        user.dateCreated = [df dateFromString:createdString];
                    }
                    
                    NSArray *editedLocations = status[@"profile_info"][@"profile_list_of_edited_locations"];
                    if (![editedLocations isKindOfClass:[NSNull class]]) {
                        Region *currentRegion = [[PinballMapManager sharedInstance] currentRegion];
                        for (int i = 0; i < [editedLocations count]; i++) {
                            NSNumber *regionId = editedLocations[i][2];

                            if (regionId == currentRegion.regionId) {
                                UserProfileEditedLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileEditedLocation" inManagedObjectContext:cdManager.managedObjectContext];
                                
                                NSNumber *locationId = editedLocations[i][0];
                                NSFetchRequest *locationFetch = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
                                locationFetch.predicate = [NSPredicate predicateWithFormat:@"locationId = %@",locationId];
                                locationFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
                                NSArray *foundLocations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:locationFetch error:nil];
                                if (foundLocations.count == 1){
                                    location.location = [foundLocations firstObject];
                                }
                            
                                NSFetchRequest *regionFetch = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
                                regionFetch.predicate = [NSPredicate predicateWithFormat:@"regionId = %@",regionId];
                                regionFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
                                NSArray *foundRegions = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:regionFetch error:nil];
                                if (foundRegions.count == 1){
                                    location.region = [foundRegions firstObject];
                                }

                                location.locationId = locationId;
                                location.regionId = regionId;
                                location.userId = user.userId;
                                location.user = user;
                            }
                        }
                    }
                    
                    NSArray *highScores = status[@"profile_info"][@"profile_list_of_high_scores"];
                    if (![highScores isKindOfClass:[NSNull class]]) {
                        for (int i = 0; i < [highScores count]; i++) {
                            UserProfileHighScore *score = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileHighScore" inManagedObjectContext:cdManager.managedObjectContext];
                            score.locationName = highScores[i][0];
                            score.machineName = highScores[i][1];
                            score.score = highScores[i][2];
                            
                            NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
                            [myFormatter setDateFormat:@"MM-dd-yyyy"];
                            score.dateCreated = [myFormatter dateFromString:highScores[i][3]];
                            score.user = user;
                        }
                    }
                    
                    [[PinballMapManager sharedInstance] loadUserData:user];
                    
                    [self dismissViewControllerAnimated:NO completion:^{}];
                }
            }];
        }
    }];
}

@end
