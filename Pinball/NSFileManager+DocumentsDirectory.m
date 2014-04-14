//
//  NSFileManager+DocumentsDirectory.m
//
//  Created by Frank Michael Sanchez on 3/27/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//  https://github.com/fmscode/Objective-C-Categories

#import "NSFileManager+DocumentsDirectory.h"

@implementation NSFileManager (DocumentsDirectory)
+ (NSString *)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
@end
