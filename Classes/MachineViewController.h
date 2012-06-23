#import "MachineFilterView.h"
#import "BlackTableViewController.h"

@interface MachineViewController : BlackTableViewController {
    NSMutableDictionary *machinesByFirstLetter;
	NSArray *keys;
	
	MachineFilterView *machineFilterView;
}

@property (nonatomic,strong) NSMutableDictionary *machinesByFirstLetter;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,strong) MachineFilterView *machineFilterView;

@end