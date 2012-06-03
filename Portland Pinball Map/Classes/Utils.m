#import "Utils.h"

@implementation Utils

+ (BOOL)stringIsBlank:(NSString *)string {
	for (int i = 0; i < [string length]; i++) {
		if(![[string substringWithRange:NSMakeRange(i,1)] isEqualToString:@" "])
            return NO;
	}
    
	return YES;
}

+ (NSString *)urlEncode:(NSString *)url {
    return [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

+ (NSString *)formatDateFromString:(NSString *)dateString {	
	NSString *year = [[NSString alloc] initWithString:[dateString substringWithRange:YEAR_RANGE]];
	NSString *month = [[NSString alloc] initWithString:[dateString substringWithRange:MONTH_RANGE]];
	NSString *displayMonth;
	
	if ([month isEqualToString:@"01"]) {
        displayMonth = [[NSString alloc] initWithString:@"Jan"];
	} else if ([month isEqualToString:@"02"]) {
        displayMonth = [[NSString alloc] initWithString:@"Feb"];
	} else if ([month isEqualToString:@"03"]) {
        displayMonth = [[NSString alloc] initWithString:@"March"];
	} else if ([month isEqualToString:@"04"]) {
        displayMonth = [[NSString alloc] initWithString:@"April"];
	} else if ([month isEqualToString:@"05"]) {
        displayMonth = [[NSString alloc] initWithString:@"May"];
    } else if ([month isEqualToString:@"06"]) {
        displayMonth = [[NSString alloc] initWithString:@"June"];
	} else if ([month isEqualToString:@"07"]) {
        displayMonth = [[NSString alloc] initWithString:@"July"];
	} else if ([month isEqualToString:@"08"]) {
        displayMonth = [[NSString alloc] initWithString:@"Aug"];
	} else if ([month isEqualToString:@"09"]) {
        displayMonth = [[NSString alloc] initWithString:@"Sep"];
	} else if ([month isEqualToString:@"10"]) {
        displayMonth = [[NSString alloc] initWithString:@"Oct"];
	} else if ([month isEqualToString:@"11"]) {
        displayMonth = [[NSString alloc] initWithString:@"Nov"];
	} else {
        displayMonth = [[NSString alloc] initWithString:@"Dec"];
    }
	
	NSRange digit;
	digit.length = 1;
	digit.location = 1;
	
	NSString *day = [[NSString alloc] initWithString:[dateString substringWithRange:NSMakeRange(8, 2)]];
	NSString *lastDigit = [[NSString alloc] initWithString:[day substringWithRange:digit]];
	NSString *extra;
    
	if ([day isEqualToString:@"11"]) {
        extra = [[NSString alloc] initWithString:@"th"];
	} else if ([day isEqualToString:@"12"]) {
        extra = [[NSString alloc] initWithString:@"th"];
	} else if ([day isEqualToString:@"13"]) {
        extra = [[NSString alloc] initWithString:@"th"];
	} else if ([lastDigit isEqualToString:@"1"]) {
        extra = [[NSString alloc] initWithString:@"st"];
	} else if ([lastDigit isEqualToString:@"2"]) {
        extra = [[NSString alloc] initWithString:@"nd"];
	} else if ([lastDigit isEqualToString:@"3"]) {
        extra = [[NSString alloc] initWithString:@"rd"];
	} else {
        extra = [[NSString alloc] initWithString:@"th"];
    }
	
	NSString *dayString = [NSString stringWithFormat:@"%i%@",[day intValue],extra];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
	return [[NSString alloc] initWithFormat:@"%@ %@, %@",displayMonth,dayString,year];	
}

+ (NSDate *)getDateFromString:(NSString *)dateString {
	NSString *day = [dateString substringWithRange:DAY_RANGE];
	NSString *year = [dateString substringWithRange:YEAR_RANGE];
	NSString *month = [dateString substringWithRange:MONTH_RANGE];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
	return [inputFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@", year, month, day]];
}

+ (NSString *)stripString:(NSString *)string {
	NSArray *escapeChars = [NSArray arrayWithObjects:
							@";", @"/", @"?", @":",
							@"@", @"&", @"=", @"+",
							@"$", @",", @"[", @"]",
							@"#", @"!", @"|", @"(", 
							@"-",
							@")", @"*", @"'", @" ", nil];
	
	int len = [escapeChars count];
    NSMutableString *temp  = [string mutableCopy];
	NSMutableString *temp2 = [[temp lowercaseString] mutableCopy];
    
	for(int i = 0; i < len; i++) {
        [temp2 replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
                               withString: @""
                                  options: NSLiteralSearch
                                    range: NSMakeRange(0, [temp2 length])];
    }
	
    return temp2;
}

@end