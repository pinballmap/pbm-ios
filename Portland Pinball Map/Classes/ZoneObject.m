#import "ZoneObject.h"

@implementation ZoneObject
@synthesize name, id_number, shortName, isPrimary;

-(void)dealloc {
	[name release];
	[id_number release];
	[shortName release];
	[isPrimary release];
	[super dealloc];
}

@end