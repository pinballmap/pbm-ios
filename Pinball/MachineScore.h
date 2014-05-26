//
//  MachineScore.h
//  Pinball
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ScoreRank) {
    ScoreRankGC = 0,
    ScoreRank1st,
    ScoreRank2nd,
    ScoreRank3rd,
    ScoreRank4th,
    ScoreRankNA
};

@interface MachineScore : NSObject

@property (nonatomic) NSString *initials;
@property (nonatomic) ScoreRank rank;
@property (nonatomic) NSNumber *score;

- (id)initWithData:(NSDictionary *)data;

@end

@interface MachineScore (Rank)

+ (NSString *)wordingForRank:(ScoreRank)rank;

@end