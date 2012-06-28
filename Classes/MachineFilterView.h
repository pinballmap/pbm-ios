#import "XMLTable.h"
#import "Machine.h"

@interface MachineFilterView : XMLTable {	
	NSMutableArray *locations;
	
	Machine *machine;
    NSMutableDictionary *foundLocation;
    
	BOOL resetNavigationStackOnLocationSelect;
	BOOL didAbortParsing;	
}

@property (nonatomic,assign) BOOL didAbortParsing;
@property (nonatomic,assign) BOOL resetNavigationStackOnLocationSelect;
@property (nonatomic,strong) NSMutableDictionary *foundLocation;
@property (nonatomic,strong) NSArray *locations;
@property (nonatomic,strong) Machine *machine;

- (void)onMapPress:(id)sender;
- (void)reloadLocationData;

@end