
#import <UIKit/UIKit.h>

@interface ProfileView : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameDateCreatedLabel;
@property (strong, nonatomic) IBOutlet UILabel *numMachinesAddedLabel;
@property (strong, nonatomic) IBOutlet UILabel *numMachinesRemovedLabel;
@property (strong, nonatomic) IBOutlet UILabel *numLocationsEditedLabel;
@property (strong, nonatomic) IBOutlet UILabel *numLocationsSuggestedLabel;
@property (strong, nonatomic) IBOutlet UILabel *numCommentsLeftLabel;

@property (strong, nonatomic) IBOutlet UITableView *highScoresTableView;
@property (strong, nonatomic) IBOutlet UITableView *editedLocationsTableView;

@end
