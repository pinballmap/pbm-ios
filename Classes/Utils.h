#define DAY_RANGE   NSMakeRange(8, 2)
#define YEAR_RANGE  NSMakeRange(0, 4)
#define MONTH_RANGE NSMakeRange(5, 2)

#define PDX_LAT 45.52295
#define PDX_LON -122.66785

@interface Utils : NSObject {
}

+ (BOOL)stringIsBlank:(NSString *)string;
+ (NSString *)urlEncode:(NSString *)url;
+ (NSString *)urlDecode:(NSString *)url;
+ (NSString *)formatDateFromString:(NSString *)dateString;
+ (NSDate *)getDateFromString:(NSString *)dateString;
+ (NSString *)stripString:(NSString *)string;
+ (NSString *)directoryFirstLetter:(NSString *)string;
+ (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;

+ (NSArray *)fetchObjects:(NSString *)type where:(NSString *)field equals:(NSString *)value inMOC:(NSManagedObjectContext*)moc;
+ (id)fetchObject:(NSString *)type where:(NSString *)field equals:(NSString *)value inMOC:(NSManagedObjectContext*)moc;

@end