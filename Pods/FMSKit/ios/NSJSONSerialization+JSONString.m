//
//  NSJSONSerialization+JSONString.m
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "NSJSONSerialization+JSONString.h"

@implementation NSJSONSerialization (JSONString)
+ (NSString *)jsonStringWithObject:(id)obj{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end
