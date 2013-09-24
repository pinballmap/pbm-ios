#import "BlackTableViewController.h"

@interface ZonesViewController : BlackTableViewController {
    NSArray *titles;
	NSDictionary *zones;
}

@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSDictionary *zones;

@end