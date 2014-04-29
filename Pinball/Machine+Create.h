//
//  Machine+Create.h
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Machine.h"

@interface Machine (Create)

+ (instancetype)createMachineWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context;

@end
