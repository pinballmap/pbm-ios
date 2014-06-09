//
//  NSFileManager+DocumentsDirectory.m
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NSFileManager+DocumentsDirectory.h"

@implementation NSFileManager (DocumentsDirectory)
+ (NSString *)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
@end
