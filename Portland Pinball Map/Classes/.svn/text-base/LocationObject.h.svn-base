//
//  LocationObject.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationObject : NSObject {
	
	NSDictionary   *machines;
	
	NSString       *name;
	NSString       *id_number;
	NSString       *neighborhood;
	CLLocation     *coords;
	NSString       *distanceString;
	NSString	   *street1;
	NSString       *street2;
	NSString       *city;
	NSString       *state;
	NSString       *zip;
	NSString	   *phone;
	
	NSString       *mapURL;
	
	int            totalMachines;
	double		   distance;
	double		   distanceRounded;
	BOOL	       isLoaded;
}

@property (nonatomic,retain) NSString       *mapURL;
@property (nonatomic,retain) NSString       *name;
@property (nonatomic,retain) NSString       *id_number;
@property (nonatomic,retain) NSString       *neighborhood;
@property (nonatomic,retain) NSString       *street1;
@property (nonatomic,retain) NSString       *street2;
@property (nonatomic,retain) NSString       *city;
@property (nonatomic,retain) NSString       *state;
@property (nonatomic,retain) NSString       *zip;
@property (nonatomic,retain) NSString		*phone;
@property (nonatomic,retain) NSDictionary   *machines;
@property (nonatomic,retain) NSString       *distanceString;
@property (nonatomic,retain) CLLocation     *coords;
@property (nonatomic,assign) BOOL isLoaded;
@property (nonatomic,assign) double distance;
@property (nonatomic,assign) double distanceRounded;
@property (nonatomic,assign) int  totalMachines;

-(void)updateDistance;

@end
