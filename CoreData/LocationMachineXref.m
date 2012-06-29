#import "LocationMachineXref.h"
#import "Location.h"
#import "Machine.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation LocationMachineXref

@dynamic condition, conditionDate, dateAdded, idNumber, location, machine;

+ (LocationMachineXref *)findForMachine:(Machine *)machine andLocation:(Location *)location {
    for (LocationMachineXref *lmx in location.locationMachineXrefs) {
        if ([lmx.machine.idNumber isEqualToNumber:machine.idNumber]) {
            return lmx;
        }
    }
    
    return nil;
}

+ (NSMutableArray *)locationsForMachine:(Machine *)machine {
    Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"LocationMachineXref" inManagedObjectContext:appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"machine == %@", machine]];
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (LocationMachineXref *lmx in [appDelegate.managedObjectContext executeFetchRequest:request error:nil]) {
        [locations addObject:lmx.location];
    }
    
    return locations;        
}

@end