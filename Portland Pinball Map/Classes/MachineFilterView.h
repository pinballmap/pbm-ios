#import "XMLTable.h"
#import "LocationMap.h"
#import "LocationObject.h"
#import <Foundation/Foundation.h>

@interface MachineFilterView : XMLTable {	
	NSMutableArray *locationArray;
	NSMutableArray *tempLocationArray;
	
	NSString *machineID;
	NSString *machineName;
	NSMutableString *temp_location_id;
	
	UILabel *noLocationsLabel;
	
	BOOL resetNavigationStackOnLocationSelect;
	BOOL didAbortParsing;
	
	LocationMap *mapView;
}
@property (nonatomic,assign) BOOL didAbortParsing;
@property (nonatomic,assign) BOOL resetNavigationStackOnLocationSelect;
@property (nonatomic,strong) NSMutableArray *tempLocationArray;
@property (nonatomic,strong) UILabel *noLocationsLabel;
@property (nonatomic,strong) LocationMap *mapView;
@property (nonatomic,strong) NSString *temp_location_id;
@property (nonatomic,strong) NSArray *locationArray;
@property (nonatomic,strong) NSString *machineID;
@property (nonatomic,strong) NSString *machineName;

- (void)onMapPress:(id)sender;
- (void)reloadLocationData;

@end