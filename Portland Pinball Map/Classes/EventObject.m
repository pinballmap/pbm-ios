#import "EventObject.h"

@implementation EventObject
@synthesize name, id_number, longDesc, link, categoryNo, startDate, endDate, locationNo, location, displayDate, displayName;

-(void)dealloc {
	[id_number release];
	[name release];
	[longDesc release];
	[link release];
	[categoryNo release];
	[startDate release];
	[endDate release];
	[locationNo release];
	[displayDate release];
	[location release];
	[displayName release];
	[super dealloc];
}

@end