#import "LocationFilterView.h"
#import "BlackTableViewController.h"

@interface ZonesViewController : BlackTableViewController {
    NSArray *titles;
	NSDictionary *zones;
	
	LocationFilterView *locationFilterView;	
}

@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSDictionary *zones;
@property (nonatomic,strong) LocationFilterView *locationFilterView;

@end