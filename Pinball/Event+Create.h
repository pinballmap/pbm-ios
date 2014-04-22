//
//  Event+Create.h
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Event.h"

@interface Event (Create)

+ (instancetype)createEventWithData:(NSDictionary *)data;

@end
