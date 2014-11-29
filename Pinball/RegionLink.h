//
//  RegionLink.h
//  PinballMap
//
//  Created by Frank Michael on 10/5/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegionLink : NSObject

@property (nonatomic) NSString *linkDescription;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *category;

- (instancetype)initWithData:(NSDictionary *)link;

@end
