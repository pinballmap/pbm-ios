//
//  NSDate+DateFormatting.m
//
//  Created by Frank Michael on 12/22/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//

#import "NSDate+DateFormatting.h"

@implementation NSDate (DateFormatting)

+ (NSDate *)dateFromString:(NSString *)dateString andFormat:(NSString *)dateFormat{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:dateFormat];
    return [df dateFromString:dateString];
}
+ (NSDate *)yearMonthDateWithString:(NSString *)dateString{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd"];
    return [df dateFromString:dateString];
}
- (NSString *)monthDayYearPretty:(BOOL)pretty{
    NSDateFormatter *df = [NSDateFormatter new];
    if (pretty){
        [df setDateFormat:@"MMMM dd, yyyy"];
    }else{
        [df setDateFormat:@"MM-dd-yyyy"];
    }
    return [df stringFromDate:self];
}
- (NSString *)yearMonthDay{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd"];
    return [df stringFromDate:self];
}
+ (NSDate *)timeWithString:(NSString *)timeString andMilitaryStatus:(BOOL)military withTimeZone:(NSString *)timeZone{
    NSDateFormatter *df = [NSDateFormatter new];
    if (!timeZone || timeZone.length != 3){
        timeZone = @"GMT";
    }
    [df setTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
    if (military){
        [df setDateFormat:@"HH:mm"];
    }else{
        [df setDateFormat:@"hh:mm a"];
    }
    return [df dateFromString:timeString];
}
- (NSString *)timeWithMilitaryStatus:(BOOL)military andTimeZone:(NSString *)timeZone{
    NSDateFormatter *df = [NSDateFormatter new];
    if (!timeZone || timeZone.length != 3){
        timeZone = @"GMT";
    }
    [df setTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
    if (military){
        [df setDateFormat:@"HH:mm"];
    }else{
        [df setDateFormat:@"hh:mm a"];
    }
    return [df stringFromDate:self];
}

@end
