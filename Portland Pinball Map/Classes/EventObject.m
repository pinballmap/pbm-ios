//
//  EventObject.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventObject.h"


@implementation EventObject
@synthesize name;
@synthesize id_number;
@synthesize longDesc;
@synthesize link;
@synthesize categoryNo;
@synthesize startDate;
@synthesize endDate;
@synthesize locationNo;
@synthesize location;
@synthesize displayDate;
@synthesize displayName;

- init
{
    if ((self = [super init]))
	{
		
	}
    return self;
}

-(void)dealloc
{
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
