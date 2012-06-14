#import "MachineFilterView.h"
#import "BlackTableViewController.h"

@interface MachineViewController : BlackTableViewController {
    NSMutableDictionary *sortedMachines;
	NSArray *keys;
	
	MachineFilterView *machineFilter;
}

@property (nonatomic,strong) NSMutableDictionary *sortedMachines;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,strong) MachineFilterView *machineFilter;

@end