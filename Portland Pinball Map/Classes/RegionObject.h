#import <Foundation/Foundation.h>

@interface RegionObject : NSObject {
	NSString *id_number;
	NSString *name;
	NSString *formalName;
	NSString *subdir;
	NSString *lat;
	NSString *lon;
	NSString *machineFilter;
	NSString *machineFilterString;
	
	NSMutableDictionary *locations;
	NSMutableDictionary *machines;
	
	NSMutableArray *primaryZones;
	NSMutableArray *secondaryZones;
	NSMutableArray *rssArray;
	NSMutableArray *rssTitles;
	NSMutableArray *eventArray;
	NSMutableArray *eventTitles;
	
	NSMutableDictionary *loadedMachines;
}

@property (nonatomic,retain) NSMutableDictionary *loadedMachines;

@property (nonatomic,retain) NSMutableArray *rssTitles;
@property (nonatomic,retain) NSMutableArray *rssArray;
@property (nonatomic,retain) NSMutableArray *eventTitles;
@property (nonatomic,retain) NSMutableArray *eventArray;

@property (nonatomic,retain) NSString *machineFilterString;
@property (nonatomic,retain) NSString *machineFilter;
@property (nonatomic,retain) NSString *formalName;
@property (nonatomic,retain) NSString *lat;
@property (nonatomic,retain) NSString *lon;
@property (nonatomic,retain) NSString *id_number;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *subdir;
@property (nonatomic,retain) NSMutableDictionary *locations;
@property (nonatomic,retain) NSMutableDictionary *machines;
@property (nonatomic,retain) NSMutableArray *primaryZones;
@property (nonatomic,retain) NSMutableArray *secondaryZones;

@end