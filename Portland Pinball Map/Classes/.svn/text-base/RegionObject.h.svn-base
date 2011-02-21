//
//  RegionObject.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RegionObject : NSObject {
	NSString *id_number;
	NSString *name;
	NSString *formalName;
	NSString *subdir;
	NSString *lat;
	NSString *lon;
	
	NSString *machineFilter;
	NSString *machineFilterString;
	
	NSMutableDictionary *locations;
	NSMutableDictionary *machines;
	
	NSMutableArray *primaryZones;
	NSMutableArray *secondaryZones;
	
	// RSS Stuff
	NSMutableArray *rssArray;
	NSMutableArray *rssTitles;
	
	// Event Stuff
	NSMutableArray *eventArray;
	NSMutableArray *eventTitles;
	
	//Closest Stuff
	//NSMutableArray *closestArray
	
	// Machine Locations
	NSMutableDictionary *loadedMachines;

}

@property (nonatomic,retain) NSMutableDictionary *loadedMachines;

@property (nonatomic,retain) NSMutableArray *rssTitles;
@property (nonatomic,retain) NSMutableArray *rssArray;
@property (nonatomic,retain) NSMutableArray *eventTitles;
@property (nonatomic,retain) NSMutableArray *eventArray;

@property (nonatomic,retain) NSString *machineFilterString;
@property (nonatomic,retain) NSString *machineFilter;
@property (nonatomic,retain) NSString *formalName;
@property (nonatomic,retain) NSString *lat;
@property (nonatomic,retain) NSString *lon;
@property (nonatomic,retain) NSString *id_number;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *subdir;
@property (nonatomic,retain) NSMutableDictionary *locations;
@property (nonatomic,retain) NSMutableDictionary *machines;
@property (nonatomic,retain) NSMutableArray *primaryZones;
@property (nonatomic,retain) NSMutableArray *secondaryZones;

@end
