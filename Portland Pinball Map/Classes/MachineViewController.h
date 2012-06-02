#import "MachineFilterView.h"
#import "BlackTableViewController.h"

@interface MachineViewController : BlackTableViewController {
    NSMutableDictionary *sortedMachines;
	NSArray *keys;
	
	MachineFilterView *machineFilter;
}

@property (nonatomic,retain) NSMutableDictionary *sortedMachines;
@property (nonatomic,retain) NSArray *keys;
@property (nonatomic,retain) MachineFilterView *machineFilter;

@end