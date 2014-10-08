//
//  MachineScore.m
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineScore.h"

@implementation MachineScore

- (id)initWithData:(NSDictionary *)data{
    self = [super init];
    if (self){
        self.initials = data[@"initials"];
        
        switch ([data[@"rank"] integerValue]) {
            case 1:
                _rank = ScoreRankGC;
                break;
            case 2:
                _rank = ScoreRank1st;
                break;
            case 3:
                _rank = ScoreRank2nd;
                break;
            case 4:
                _rank = ScoreRank3rd;
                break;
            case 5:
                _rank = ScoreRank4th;
                break;
            default:
                _rank = ScoreRankNA;
                break;
        }
        self.score = data[@"score"];
        NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
        numFormat.numberStyle = NSNumberFormatterDecimalStyle;

        self.scoreString = [numFormat stringFromNumber:self.score];
    }
    return self;
}

@end

@implementation MachineScore (Rank)

+ (NSString *)wordingForRank:(ScoreRank)rank{
    switch (rank) {
        case ScoreRankGC:
            return @"GC";
            break;
        case ScoreRank1st:
            return @"1st";
            break;
        case ScoreRank2nd:
            return @"2nd";
            break;
        case ScoreRank3rd:
            return @"3rd";
            break;
        case ScoreRank4th:
            return @"4th";
            break;
        case ScoreRankNA:
            return @"N/A";
            break;
        default:
            break;
    }
    return @"";
}

@end
