//
//  HighRollers.m
//  PinballMap
//
//  Created by Frank Michael on 10/7/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "HighRoller.h"

@implementation HighRoller

- (instancetype)initWithInitials:(NSString *)initials andScores:(NSArray *)scoresData{
    self = [super init];
    if (self){
        self.initials = initials;
        self.highScores = [NSMutableArray new];
        
        for (NSDictionary *score in scoresData) {
            HighScore *highScore = [[HighScore alloc] initWithData:score];
            [self.highScores addObject:highScore];
        }
        
    }
    return self;
}

@end
