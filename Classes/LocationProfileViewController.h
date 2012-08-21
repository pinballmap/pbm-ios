#import "XMLTable.h"
#import "Location.h"

@interface LocationProfileViewController : XMLTable {	  
	UIScrollView *scrollView;

    NSMutableString *mapURL;
	
	Location *activeLocation;
	
	UILabel *mapLabel;
	UIButton *mapButton;
	BOOL showMapButton;
			
	BOOL isBuildingMachine;
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
}

@property (nonatomic,strong) IBOutlet UIButton *addMachineButton;
@property (nonatomic,assign) BOOL showMapButton;
@property (nonatomic,strong) IBOutlet UILabel *mapLabel;
@property (nonatomic,strong) IBOutlet UIButton *mapButton;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) Location *activeLocation;
@property (nonatomic,assign) BOOL isBuildingMachine;
@property (nonatomic,strong) NSMutableString *tempMachineID;
@property (nonatomic,strong) NSMutableString *tempMachineConditionDate;
@property (nonatomic,strong) NSMutableString *tempMachineCondition;
@property (nonatomic,strong) NSMutableString *tempMachineDateAdded;

- (IBAction)mapButtonPressed:(id)sender;
- (IBAction)addMachineButtonPressed:(id)sender;
- (void)refreshAndReload;
- (void)loadLocationData;

@end