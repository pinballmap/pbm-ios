#import "XMLTable.h"
#import "MachineProfileViewController.h"
#import "AddMachineViewController.h"
#import "MachineObject.h"
#import "LocationObject.h"
#import "LocationMap.h"
#import <Foundation/Foundation.h>

@interface LocationProfileViewController : XMLTable {	  
	NSString *message;
	UIScrollView *scrollView;
	NSString *locationID;
	
	LocationMap *mapView;
	
	NSMutableDictionary *masterDictionary;
	
	LocationObject *activeLocationObject;
	
	NSMutableString *mapURL;
	
	NSMutableDictionary *info;
	
	UILabel *mapLabel;
	UIButton *mapButton;
	BOOL showMapButton;
	
	UIView *__unsafe_unretained lineView;
	
	NSMutableArray *label_holder;
	
	BOOL building_machine;
	MachineObject *temp_machine_object;
	NSMutableDictionary *temp_machine_dict;
	NSMutableString *temp_machine_name;
	NSMutableString *temp_machine_id;
	NSMutableString *temp_machine_condition;
	NSMutableString *temp_machine_condition_date;
	NSMutableString *temp_machine_dateAdded;
	
	NSMutableString *current_street1;
	NSMutableString *current_street2;
	NSMutableString *current_city;
	NSMutableString *current_state;
	NSMutableString *current_zip;
	NSMutableString *current_phone;
	
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
@property (nonatomic,assign) BOOL building_machine;
@property (nonatomic,strong) NSMutableArray *label_holder;
@property (nonatomic,strong) MachineObject *temp_machine_object;
@property (nonatomic,strong) NSMutableDictionary *temp_machine_dict;
@property (nonatomic,strong) NSMutableString *temp_machine_name;
@property (nonatomic,strong) NSMutableString *temp_machine_id;
@property (nonatomic,strong) NSMutableString *temp_machine_condition_date;
@property (nonatomic,strong) NSMutableString *temp_machine_condition;
@property (nonatomic,strong) NSMutableString *temp_machine_dateAdded;
@property (nonatomic,strong) NSMutableArray *displayArray;

- (IBAction)mapButtonPressed:(id)sender;
- (IBAction)addMachineButtonPressed:(id)sender;
- (void)refreshAndReload;
- (void)loadLocationData;

+ (NSString *)urlDecodeValue:(NSString *)url;
+ (NSString *)urlencode: (NSString *)url;

@end