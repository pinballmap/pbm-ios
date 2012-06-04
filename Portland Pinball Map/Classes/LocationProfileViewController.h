#import "XMLTable.h"
#import "MachineProfileViewController.h"
#import "AddMachineViewController.h"
#import "MachineObject.h"
#import "LocationObject.h"
#import "LocationMap.h"
#import <Foundation/Foundation.h>

@interface LocationProfileViewController : XMLTable {	  
	UIScrollView *scrollView;

	NSString *locationID;
	NSString *message;
    NSMutableString *mapURL;
	
	LocationMap *mapView;
	
	NSMutableDictionary *masterDictionary;
	
	LocationObject *activeLocationObject;

	NSMutableDictionary *info;
	
	UILabel *mapLabel;
	UIButton *mapButton;
	BOOL showMapButton;
	
	UIView *__unsafe_unretained lineView;
	
	NSMutableArray *labelHolder;
	
	BOOL isBuildingMachine;
	MachineObject *tempMachineObject;
	NSMutableDictionary *tempMachineDict;
	NSMutableString *tempMachineName;
	NSMutableString *tempMachineID;
	NSMutableString *tempMachineCondition;
	NSMutableString *tempMachineConditionDate;
	NSMutableString *tempMachineDateAdded;
	NSMutableString *currentStreet1;
	NSMutableString *currentStreet2;
	NSMutableString *currentCity;
	NSMutableString *currentState;
	NSMutableString *currentZip;
	NSMutableString *currentPhone;
	
	int parsingAttempts;
	
	UIButton *addMachineButton;
	
	AddMachineViewController *addMachineView;
	MachineProfileViewController *machineProfileView;
	
	NSMutableArray *displayArray;
}

@property (nonatomic,strong) MachineProfileViewController *machineProfileView;
@property (nonatomic,strong) AddMachineViewController *addMachineView;
@property (nonatomic,strong) IBOutlet UIButton *addMachineButton;
@property (nonatomic,assign) BOOL showMapButton;
@property (nonatomic,strong) LocationMap *mapView;
@property (nonatomic,unsafe_unretained) IBOutlet UIView *lineView;
@property (nonatomic,strong) IBOutlet UILabel *mapLabel;
@property (nonatomic,strong) IBOutlet UIButton *mapButton;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *locationID;
@property (nonatomic,strong) LocationObject *activeLocationObject;
@property (nonatomic,assign) BOOL isBuildingMachine;
@property (nonatomic,strong) NSMutableArray *labelHolder;
@property (nonatomic,strong) MachineObject *tempMachineObject;
@property (nonatomic,strong) NSMutableDictionary *tempMachineDict;
@property (nonatomic,strong) NSMutableString *tempMachineName;
@property (nonatomic,strong) NSMutableString *tempMachineID;
@property (nonatomic,strong) NSMutableString *tempMachineConditionDate;
@property (nonatomic,strong) NSMutableString *tempMachineCondition;
@property (nonatomic,strong) NSMutableString *tempMachineDateAdded;
@property (nonatomic,strong) NSMutableArray *displayArray;

- (IBAction)mapButtonPressed:(id)sender;
- (IBAction)addMachineButtonPressed:(id)sender;
- (void)refreshAndReload;
- (void)loadLocationData;

@end