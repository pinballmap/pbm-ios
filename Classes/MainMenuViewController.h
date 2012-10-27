#import "AboutViewController.h"
#import "XMLTable.h"
#import "ClosestLocations.h"
#import "RecentlyAddedViewController.h"
#import "EventsViewController.h"
#import "ZonesViewController.h"
#import "MachineViewController.h"

@interface MainMenuViewController : XMLTable <UIAlertViewDelegate, UIAccelerometerDelegate> {
	NSArray *controllers;
	AboutViewController *aboutView;
	
    NSString *motd;
    NSString *activeNode;
	
    NSArray *tableTitles;   
}

@property (nonatomic,strong) CLLocation *startingPoint;
@property (nonatomic,strong) NSArray *tableTitles;
@property (nonatomic,strong) NSArray *controllers;
@property (nonatomic,strong) AboutViewController *aboutView;

- (void)pressInfo:(id)sender;
- (void)showInfoButton;

@end