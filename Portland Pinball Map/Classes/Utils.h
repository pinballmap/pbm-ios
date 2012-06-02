#import <Foundation/Foundation.h>

@interface Utils : NSObject {
}

+ (BOOL) stringIsBlank:(NSString *)string;
+ (void)sendErrorReport:(NSString *)string;
+ (NSString *)urlencode:(NSString *)url;

@end