//
//  MachineCondition.h
//  PinballMap
//
//  Created by Frank Michael on 10/21/15.
//  Copyright © 2015 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MachineLocation;

@interface MachineCondition : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * conditionCreated;
@property (nonatomic, retain) NSNumber * conditionId;
@property (nonatomic, retain) MachineLocation *machineLocation;

@end
