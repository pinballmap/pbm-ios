//
//  MachineScore.h
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MachineScore : NSObject

@property (nonatomic) NSNumber *score;
@property (nonatomic) NSString *scoreString;
@property (nonatomic) NSString *createdByUsername;
@property (nonatomic) NSDate *dateCreated;

- (id)initWithData:(NSDictionary *)data;

@end
