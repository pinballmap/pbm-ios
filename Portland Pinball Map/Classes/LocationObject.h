#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationObject : NSObject {	
    CLLocation *coords;
	NSDictionary *machines;
	
	NSString *name;
	NSString *idNumber;
	NSString *neighborhood;
	NSString *distanceString;
	NSString *street1;
	NSString *street2;
	NSString *city;
	NSString *state;
	NSString *zip;
	NSString *phone;
	
	NSString *mapURL;
	
	int totalMachines;
	double distance;
	double distanceRounded;
    BOOL isLoaded;
}

@property (nonatomic,strong) NSString *mapURL;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *idNumber;
@property (nonatomic,strong) NSString *neighborhood;
@property (nonatomic,strong) NSString *street1;
@property (nonatomic,strong) NSString *street2;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *zip;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *distanceString;
@property (nonatomic,strong) NSDictionary *machines;
@property (nonatomic,strong) CLLocation *coords;
@property (nonatomic,assign) BOOL isLoaded;
@property (nonatomic,assign) double distance;
@property (nonatomic,assign) double distanceRounded;
@property (nonatomic,assign) int totalMachines;

- (void)updateDistance;

@end