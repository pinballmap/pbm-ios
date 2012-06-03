#import <Foundation/Foundation.h>

#define DAY_RANGE   NSMakeRange(8, 2)
#define YEAR_RANGE  NSMakeRange(0, 4)
#define MONTH_RANGE NSMakeRange(5, 2)

@interface Utils : NSObject {
}

+ (BOOL)stringIsBlank:(NSString *)string;
+ (NSString *)urlEncode:(NSString *)url;
+ (NSString *)formatDateFromString:(NSString *)dateString;
+ (NSDate *)getDateFromString:(NSString *)dateString;
+ (NSString *)stripString:(NSString *)string;

@end