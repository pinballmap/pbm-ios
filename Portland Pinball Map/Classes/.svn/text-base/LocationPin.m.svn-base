//
//  LocationPin.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationPin.h"


@implementation LocationPin
@synthesize coordinate;
@synthesize location;

- (NSString *)subtitle
{
	//NSMutableString *sub = [[[NSMutableString alloc] initWithString:@""] autorelease];
	/*for(id key in location.machines)
	{
		MachineObject *machineObject = (MachineObject *)[location.machines objectForKey:key];
		//NSLog(@"%@",machineObject.name);
		[sub appendFormat:@"%@\n",machineObject.name];
	}*/
	 
	return location.street1;
}

- (NSString *)title{
	return location.name;
}

-(id)initWithLocation:(LocationObject *)newLocation
{
	location = newLocation;
	return [self initWithCoordinate:location.coords.coordinate];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

-(void)dealloc
{
	[location release];
	[super dealloc];
}

@end
