//
//  SafariActivity.m
//  Reddit Reader
//
//  Created by Frank Michael on 4/25/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "SafariActivity.h"

@interface SafariActivity () {
    NSArray *items;
}

@end

@implementation SafariActivity

- (id)init{
    self = [super init];
    if (self){
        items = [[NSArray alloc] init];
    }
    return self;
}

- (NSString *)activityType{
    return @"SafariRedirect";
}
- (NSString *)activityTitle{
    return @"Open in Safari";
}
- (UIImage *)activityImage{
    return [UIImage imageNamed:@"782-compass"];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    items = activityItems;
    return YES;
}
- (void)performActivity{
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:obj]];
        }else if ([obj isKindOfClass:[NSURL class]]){
            [[UIApplication sharedApplication] openURL:obj];
        }
    }];
}
@end
