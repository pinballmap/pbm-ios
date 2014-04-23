//
//  Event.h
//  Pinball
//
//  Created by Frank Michael on 4/23/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Region;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * categoryNo;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Region *region;

@end
