//
//  RegionLink.m
//  PinballMap
//
//  Created by Frank Michael on 10/5/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "RegionLink.h"

@implementation RegionLink


- (instancetype)initWithData:(NSDictionary *)link{
    self = [super init];
    if (self){
        self.linkDescription = link[@"description"];
        if ([link[@"description"] isKindOfClass:[NSNull class]]){
            self.linkDescription = @"";
        }
        self.name = link[@"name"];
        self.url = link[@"url"];
        
        if ([link[@"category"] isKindOfClass:[NSNull class]]){
            self.category = @"Links";
        }else{
            self.category = link[@"category"];
        }
    }
    return self;
}

@end
