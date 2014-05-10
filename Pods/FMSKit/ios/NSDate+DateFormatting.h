//
//  NSDate+DateFormatting.h
//
//  Created by Frank Michael on 12/22/13.
//  Copyright (c) 2013 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateFormatting)

+ (NSDate *)dateFromString:(NSString *)dateString andFormat:(NSString *)dateFormat;
// Converts a yyyy-mm-dd string to a NSDate object.
+ (NSDate *)yearMonthDateWithString:(NSString *)dateString;
// Converts a NSDate to a month-day-year format.
// If pretty is true will return a word based date: September 10, 2014
- (NSString *)monthDayYearPretty:(BOOL)pretty;
// Converts a NSDate to a NSString with a yyyy-mm-dd format.
- (NSString *)yearMonthDay;
// Creates a NSDate from either a 12 hour formatted time or 24 hour format. If no timezone is set will default to GMT
+ (NSDate *)timeWithString:(NSString *)timeString andMilitaryStatus:(BOOL)military withTimeZone:(NSString *)timeZone;;
// Creates NSString with either a 12 hour format, military=NO, or a 24 hour format, military=YES. If no timezone is set will default to GMT
- (NSString *)timeWithMilitaryStatus:(BOOL)military andTimeZone:(NSString *)timeZone;
@end
