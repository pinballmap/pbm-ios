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
	
	CLLocationDistance mDistance = [appDelegate.userLocation getDistanceFrom:coords] / 1609.344;
	
	NSNumber *distanceNumber = [[NSNumber alloc] initWithDouble:mDistance]; 
	NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
	[numberFormat setMinimumIntegerDigits:1];	
	[numberFormat setMaximumFractionDigits:1];
	[numberFormat setMinimumFractionDigits:1];
	
	distance = mDistance;
	distanceRounded = [[numberFormat stringFromNumber:distanceNumber] doubleValue];    
	distanceString = [[NSString alloc] initWithFormat:@"%@ mi", [numberFormat stringFromNumber:distanceNumber]];
}

@end