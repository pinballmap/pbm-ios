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

+ (NSString *)urlDecode:(NSString *)url {
    NSString *result = [url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    
}

+ (NSString *)formatDateFromString:(NSString *)dateString {
    if ([dateString isEqualToString:@""])
        return dateString;
    
	NSString *year = [[NSString alloc] initWithString:[dateString substringWithRange:YEAR_RANGE]];
	NSString *month = [[NSString alloc] initWithString:[dateString substringWithRange:MONTH_RANGE]];
	NSString *displayMonth;
	
	if ([month isEqualToString:@"01"]) {
        displayMonth = @"Jan";
	} else if ([month isEqualToString:@"02"]) {
        displayMonth = @"Feb";
	} else if ([month isEqualToString:@"03"]) {
        displayMonth = @"March";
	} else if ([month isEqualToString:@"04"]) {
        displayMonth = @"April";
	} else if ([month isEqualToString:@"05"]) {
        displayMonth = @"May";
    } else if ([month isEqualToString:@"06"]) {
        displayMonth = @"June";
	} else if ([month isEqualToString:@"07"]) {
        displayMonth = @"July";
	} else if ([month isEqualToString:@"08"]) {
        displayMonth = @"Aug";
	} else if ([month isEqualToString:@"09"]) {
        displayMonth = @"Sep";
	} else if ([month isEqualToString:@"10"]) {
        displayMonth = @"Oct";
	} else if ([month isEqualToString:@"11"]) {
        displayMonth = @"Nov";
	} else {
        displayMonth = @"Dec";
    }
	
	NSRange digit;
	digit.length = 1;
	digit.location = 1;
	
	NSString *day = [[NSString alloc] initWithString:[dateString substringWithRange:NSMakeRange(8, 2)]];
	NSString *lastDigit = [[NSString alloc] initWithString:[day substringWithRange:digit]];
	NSString *extra;
    
	if ([day isEqualToString:@"11"]) {
        extra = @"th";
	} else if ([day isEqualToString:@"12"]) {
        extra = @"th";
	} else if ([day isEqualToString:@"13"]) {
        extra = @"th";
	} else if ([lastDigit isEqualToString:@"1"]) {
        extra = @"st";
	} else if ([lastDigit isEqualToString:@"2"]) {
        extra = @"nd";
	} else if ([lastDigit isEqualToString:@"3"]) {
        extra = @"rd";
	} else {
        extra = @"th";
    }
	
	NSString *dayString = [NSString stringWithFormat:@"%i%@",[day intValue],extra];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
	return [[NSString alloc] initWithFormat:@"%@ %@, %@",displayMonth,dayString,year];	
}

+ (NSDate *)getDateFromString:(NSString *)dateString {
    if ([dateString isEqualToString:@""])
        return nil;
    
	NSString *day = [dateString substringWithRange:DAY_RANGE];
	NSString *year = [dateString substringWithRange:YEAR_RANGE];
	NSString *month = [dateString substringWithRange:MONTH_RANGE];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
	return [inputFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@", year, month, day]];
}

+ (NSString *)stripString:(NSString *)string {
	NSArray *escapeChars = @[@";", @"/", @"?", @":",
							@"@", @"&", @"=", @"+",
							@"$", @",", @"[", @"]",
							@"#", @"!", @"|", @"(", 
							@"-",
							@")", @"*", @"'", @" "];
	
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

+ (NSString *)directoryFirstLetter:(NSString *)string {
    NSString *firstLetter = [[string substringToIndex:1] lowercaseString];
	NSString *searchString = @"abcdefghijklmnopqrstuvwxyz";
    
	NSRange letterRange = [searchString rangeOfString:firstLetter];
	if (letterRange.length == 0) {
		firstLetter = @"#";
	}
    
    return firstLetter;
}

+ (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:toDate toDate:startDate options:0];
    NSInteger days = [components day];
    
    return days;
}

+ (NSArray *)fetchObjects:(NSString *)type where:(NSString *)field equals:(NSString *)value inMOC:(NSManagedObjectContext*)moc {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:type inManagedObjectContext:moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = %@", field, value]]];
    
    return [moc executeFetchRequest:request error:nil];
}

+ (id)fetchObject:(NSString *)type where:(NSString *)field equals:(NSString *)value inMOC:(NSManagedObjectContext*)moc{
    NSArray *objects = [Utils fetchObjects:type where:field equals:value inMOC:moc];
    
    return [objects count] > 0 ? objects[0] : nil;
}

@end