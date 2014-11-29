//
//  HighScore.h
//  PinballMap
//
//  Created by Frank Michael on 10/7/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Machine.h"

@interface HighScore : NSObject

@property (nonatomic) Machine *machine;
@property (nonatomic) NSNumber *score;
@property (nonatomic) NSString *rank;

- (instancetype)initWithData:(NSDictionary *)scoreData;

@end
