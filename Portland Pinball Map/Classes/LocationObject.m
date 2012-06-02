#import "LocationObject.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation LocationObject
@synthesize neighborhood, name, id_number, machines, distanceString, mapURL, street1, street2, city, state, zip, phone, coords, distance, distanceRounded, totalMachines, isLoaded;

- init {
    if ((self = [super init])) {
       self.isLoaded = NO;
    }
    return self;
}

- (void)updateDistance {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	CLLocationDistance quickDist = [appDelegate.userLocation getDistanceFrom:coords] / 1609.344;
	
	NSNumber *distNum = [[NSNumber alloc] initWithDouble:quickDist]; 
	NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
	[numberFormat setMinimumIntegerDigits:1];	
	[numberFormat setMaximumFractionDigits:1];
	[numberFormat setMinimumFractionDigits:1];
	
	distance = quickDist;
	distanceRounded = [[numberFormat stringFromNumber:distNum] doubleValue];
	if(distanceString != nil) {
		distanceString = nil;
		[distanceString release];
	}
	distanceString = [[NSString alloc] initWithFormat:@"%@ mi", [numberFormat stringFromNumber:distNum]];
	
	[distNum release];
	[numberFormat release];
}

- (void)dealloc {
	[distanceString release];
	
	[name release];
	[street1 release];
	[street2 release];
	[city release];
	[state release];
	[zip release];
	[phone release];
	
	[mapURL release];
	[name release];
	[id_number release];
	[machines release];
	[coords release];
	[neighborhood release];
	[super dealloc];
}

@end