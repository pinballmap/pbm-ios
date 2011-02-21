//
//  EventObject.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationObject.h"


@interface EventObject : NSObject {
	NSString *id_number;
	NSString *name;
	NSString *longDesc;
	NSString *link;
	NSString *categoryNo;
	NSString *startDate;
	NSString *endDate;
	NSString *locationNo;
	
	LocationObject *location;
	NSString *displayDate;
	NSString *displayName;
		
}

@property (nonatomic,retain) NSString *id_number;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *longDesc;
@property (nonatomic,retain) NSString *link;
@property (nonatomic,retain) NSString *categoryNo;
@property (nonatomic,retain) NSString *startDate;
@property (nonatomic,retain) NSString *endDate;
@property (nonatomic,retain) NSString *locationNo;

@property (nonatomic,retain) LocationObject *location;
@property (nonatomic,retain) NSString *displayDate;
@property (nonatomic,retain) NSString *displayName;

@end