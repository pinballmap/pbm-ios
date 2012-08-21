#import "BlackTableViewController.h"

@interface MachineViewController : BlackTableViewController {
    NSMutableDictionary *machinesByFirstLetter;
	NSArray *keys;	
}

@property (nonatomic,strong) NSMutableDictionary *machinesByFirstLetter;
@property (nonatomic,strong) NSArray *keys;

@end