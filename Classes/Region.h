@interface Region : NSObject {
	NSString *idNumber;
	NSString *name;
	NSString *formalName;
	NSString *subdir;
	NSString *lat;
	NSString *lon;
	NSString *machineFilter;
	NSString *machineFilterString;
	
	NSMutableDictionary *locations;
	NSMutableDictionary *machines;
	NSMutableDictionary *loadedMachines;
	
	NSMutableArray *primaryZones;
	NSMutableArray *secondaryZones;
	NSMutableArray *recentlyAdded;
	NSMutableArray *events;
	NSMutableArray *eventTitles;	
}

@property (nonatomic,strong) NSMutableDictionary *loadedMachines;
@property (nonatomic,strong) NSMutableDictionary *locations;
@property (nonatomic,strong) NSMutableDictionary *machines;

@property (nonatomic,strong) NSMutableArray *recentlyAdded;
@property (nonatomic,strong) NSMutableArray *eventTitles;
@property (nonatomic,strong) NSMutableArray *events;
@property (nonatomic,strong) NSMutableArray *primaryZones;
@property (nonatomic,strong) NSMutableArray *secondaryZones;

@property (nonatomic,strong) NSString *machineFilterString;
@property (nonatomic,strong) NSString *machineFilter;
@property (nonatomic,strong) NSString *formalName;
@property (nonatomic,strong) NSString *lat;
@property (nonatomic,strong) NSString *lon;
@property (nonatomic,strong) NSString *idNumber;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *subdir;

@end