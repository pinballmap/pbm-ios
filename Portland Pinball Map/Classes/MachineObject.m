#import "MachineObject.h"

@implementation MachineObject
@synthesize name, id_number, condition, condition_date, dateAdded;

- (void)dealloc {
	[name release];
	[id_number release];
	[condition release];
	[condition_date release];
	[dateAdded release];
	[super dealloc];
}

@end