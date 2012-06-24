#import "LocationFilterView.h"
#import "BlackTableViewController.h"

@interface ZonesViewController : BlackTableViewController {
	NSDictionary *zones;
	NSArray *titles;
	
	LocationFilterView *locationFilterView;	
}

@property (nonatomic,strong) NSDictionary *zones;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) LocationFilterView *locationFilterView;

@end