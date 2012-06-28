#import "LocationMachineXref.h"
#import "Location.h"
#import "Machine.h"
#import "RecentAddition.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation LocationMachineXref

@dynamic condition, conditionDate, dateAdded, idNumber, location, machine, recentAddition;

+ (LocationMachineXref *)findForMachine:(Machine *)machine andLocation:(Location *)location {
    Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"LocationMachineXref" inManagedObjectContext:appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"machine == %@ and location == %@", machine, location]];
    
    NSArray *lmxes = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    
    return [lmxes count] > 0 ? [lmxes objectAtIndex:0] : nil;    
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