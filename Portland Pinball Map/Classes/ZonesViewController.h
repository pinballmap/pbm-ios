#import "LocationFilterView.h"
#import "BlackTableViewController.h"

@interface ZonesViewController : BlackTableViewController {
	NSDictionary *zones;
	NSArray *titles;
	
	LocationFilterView *locationFilter;	
}

@property (nonatomic,retain) NSDictionary *zones;
@property (nonatomic,retain) NSArray *titles;
@property (nonatomic,retain) LocationFilterView *locationFilter;

@end