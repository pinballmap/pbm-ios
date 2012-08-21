#import "Location.h"
#import "Event.h"
#import "LocationMachineXref.h"
#import "Region.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation Location

@synthesize distance;

@dynamic city, idNumber, lat, lon, name, phone, state, street1, street2, totalMachines, zip, events, locationMachineXrefs, locationZone, region, recentAdditions;

- (void)updateDistance {
    Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CLLocationDistance mDistance = [appDelegate.userLocation distanceFromLocation:[self coordinates]] / METERS_IN_A_MILE;
    distance = mDistance;
}

- (CLLocation *)coordinates {
    return [[CLLocation alloc] initWithLatitude:[self.lat floatValue] longitude:[self.lon floatValue]];
}

- (NSString *)formattedDistance {
    NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
    [numberFormat setMinimumIntegerDigits:1];
    [numberFormat setMaximumFractionDigits:1];
    [numberFormat setMinimumFractionDigits:1];
    
    return [NSString stringWithFormat:@"%@ mi", [numberFormat stringFromNumber:@(distance)]];
}

- (bool)isLoaded {
    // street1 is only filled out when the app hits the location detail screen, it is considered "loaded" at this point
    return (self.street1 != (id)[NSNull null] && self.street1.length != 0 && ![self.street1 isEqualToString:@"(null)"]);
}

@end