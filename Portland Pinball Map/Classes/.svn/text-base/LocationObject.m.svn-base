//
//  LocationObject.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationObject.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation LocationObject
@synthesize neighborhood;
@synthesize name;
@synthesize id_number;
@synthesize machines;
@synthesize distanceString;
@synthesize mapURL;
@synthesize street1;
@synthesize street2;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize phone;


@synthesize coords;
@synthesize distance;
@synthesize distanceRounded;
@synthesize totalMachines;
@synthesize isLoaded;

- init
{
    if ((self = [super init])) {
       self.isLoaded = NO;
    }
    return self;
}

-(void)updateDistance
{
	//NSLog(@"update dist - %@",name);
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	CLLocationDistance  quickDist = [appDelegate.userLocation getDistanceFrom:coords] / 1609.344;
	
	NSNumber          *distNum      = [[NSNumber alloc] initWithDouble:quickDist]; 
	NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
	[numberFormat setMinimumIntegerDigits:1];	
	[numberFormat setMaximumFractionDigits:1];
	[numberFormat setMinimumFractionDigits:1];
	
	distance          = quickDist;
	distanceRounded   = [[numberFormat stringFromNumber:distNum] doubleValue];
	if(distanceString != nil)
	{
		distanceString = nil;
		[distanceString release];
	}
	distanceString    = [[NSString alloc] initWithFormat:@"%@ mi", [numberFormat stringFromNumber:distNum]];
	
	[distNum release];
	[numberFormat release];
	//NSLog(@"/update dist");
}

- (void)dealloc
{
	[distanceString release];
	
	[name release];
	[street1 release];
	[street2 release];
	[city release];
	[state release];
	[zip release];
	[phone release];
	
	[mapURL release];
	[name release];
	[id_number release];
	[machines release];
	[coords release];
	[neighborhood release];
	[super dealloc];
}

@end
