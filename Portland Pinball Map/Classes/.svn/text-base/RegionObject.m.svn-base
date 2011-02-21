//
//  RegionObject.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RegionObject.h"


@implementation RegionObject
@synthesize name;
@synthesize id_number;
@synthesize subdir;
@synthesize locations;
@synthesize machines;
@synthesize primaryZones;
@synthesize secondaryZones;
@synthesize lat;
@synthesize lon;
@synthesize formalName;
@synthesize rssArray;
@synthesize rssTitles;
@synthesize eventArray;
@synthesize eventTitles;
@synthesize loadedMachines;
@synthesize machineFilter;
@synthesize machineFilterString;

- init
{
    if ((self = [super init])) {
		//self.isLoaded = NO;
    }
    return self;
}

-(void)dealloc
{
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
