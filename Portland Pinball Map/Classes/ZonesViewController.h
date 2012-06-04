#import "LocationFilterView.h"
#import "BlackTableViewController.h"

@interface ZonesViewController : BlackTableViewController {
	NSDictionary *zones;
	NSArray *titles;
	
	LocationFilterView *locationFilter;	
}

@property (nonatomic,strong) NSDictionary *zones;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) LocationFilterView *locationFilter;

@end