//
//  CoreDataManager.h
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

+ (id)sharedInstance;
- (void)saveContext;
- (NSManagedObjectContext *)resetStore;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;


@end
