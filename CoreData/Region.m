#import "Region.h"
#import "Event.h"
#import "Location.h"
#import "Zone.h"
#import "RecentAddition.h"
#import "LocationMachineXref.h"

@implementation Region

@dynamic formalName, idNumber, lat, lon, name, subdir, nMachines, events, locations, machines, recentAdditions, zones;

- (CLLocation *)coordinates {
    return [[CLLocation alloc] initWithLatitude:[self.lat floatValue] longitude:[self.lon floatValue]];
}

- (NSString *)formattedNMachines {
    return [NSString stringWithFormat:@"%d+ Machines", [self.nMachines intValue]];
}

- (NSArray *)sortedMachines {
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    return [self.machines sortedArrayUsingDescriptors:@[byName]];
}

- (NSMutableArray *)primaryZones {
    NSMutableArray *primaryZones = [[NSMutableArray alloc] init];
    for (Zone *zone in self.zones) {
        if (zone.isPrimary) {
            [primaryZones addObject:zone];
        }
    }
    
    return (NSMutableArray *)[primaryZones sortedArrayUsingComparator:^NSComparisonResult(Zone *a, Zone *b) {
        return [a.name compare:b.name];
    }];
}

- (NSMutableArray *)secondaryZones {
    NSMutableArray *secondaryZones = [[NSMutableArray alloc] init];
    for (Zone *zone in self.zones) {
        if (!zone.isPrimary) {
            [secondaryZones addObject:zone];
        }
    }
    
    return (NSMutableArray *)[secondaryZones sortedArrayUsingComparator:^NSComparisonResult(Zone *a, Zone *b) {
        return [a.name compare:b.name];
    }];
}

@end