#import "RegionObject.h"

@implementation RegionObject
@synthesize name, id_number, subdir, locations, machines, primaryZones, secondaryZones, lat, lon, formalName, rssArray, rssTitles, eventArray, eventTitles, loadedMachines, machineFilter, machineFilterString;

- (void)dealloc {
	[machineFilterString release];
	[machineFilter release];
	[loadedMachines release];
	[eventArray release];
	[eventTitles release];
	[rssTitles release];
	[rssArray release];
	[lat release];
	[lon release];
	[formalName release];
	[primaryZones release];
	[secondaryZones release];
	[id_number release];
	[name release];
	[subdir release];
	[locations release];
	[machines release];
	[super dealloc];
}

@end