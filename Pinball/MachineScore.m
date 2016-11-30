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
        self.score = data[@"score"];
        NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
        numFormat.numberStyle = NSNumberFormatterDecimalStyle;

        self.scoreString = [numFormat stringFromNumber:self.score];
        
        if (![data[@"username"] isKindOfClass:[NSNull class]]) {
            self.createdByUsername = data[@"username"];
        }
        
        if (![data[@"created_at"] isKindOfClass:[NSNull class]]) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"YYYY-MM-dd"];

            NSString *createdString = data[@"created_at"];
            createdString = [createdString substringToIndex:[createdString rangeOfString:@"T"].location];
            self.dateCreated = [df dateFromString:createdString];            
        } else {
            self.dateCreated = NULL;
        }
    }
    
    return self;
}

@end
