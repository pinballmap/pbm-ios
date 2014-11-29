//
//  HighRollers.h
//  PinballMap
//
//  Created by Frank Michael on 10/7/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HighScore.h"

@interface HighRoller : NSObject

@property (nonatomic) NSString *initials;
@property (nonatomic) NSMutableArray *highScores;

- (instancetype)initWithInitials:(NSString *)initials andScores:(NSArray *)scoresData;

@end
