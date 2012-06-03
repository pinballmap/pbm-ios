#import "XMLTable.h"
#import "LocationMap.h"
#import <Foundation/Foundation.h>

@interface MachineFilterView : XMLTable {	
	NSMutableArray *locations;
	NSMutableArray *tempLocations;
	
	NSString *machineID;
	NSString *machineName;
	NSMutableString *tempLocationID;
	
	UILabel *noLocationsLabel;
	
	BOOL resetNavigationStackOnLocationSelect;
	BOOL didAbortParsing;
	
	LocationMap *mapView;
}

@property (nonatomic,assign) BOOL didAbortParsing;
@property (nonatomic,assign) BOOL resetNavigationStackOnLocationSelect;
@property (nonatomic,strong) NSMutableArray *tempLocations;
@property (nonatomic,strong) UILabel *noLocationsLabel;
@property (nonatomic,strong) LocationMap *mapView;
@property (nonatomic,strong) NSString *tempLocationID;
@property (nonatomic,strong) NSArray *locations;
@property (nonatomic,strong) NSString *machineID;
@property (nonatomic,strong) NSString *machineName;

- (void)onMapPress:(id)sender;
- (void)reloadLocationData;

@end