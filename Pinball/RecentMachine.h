//
//  RecentMachine.h
//  PinballMap
//
//  Created by Frank Michael on 9/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentMachine : NSObject

@property (nonatomic) NSString *createdOn;
@property (nonatomic) Location *location;
@property (nonatomic) Machine *machine;
@property (nonatomic) NSMutableAttributedString *displayText;

- (instancetype)initWithData:(NSDictionary *)data;

@end
