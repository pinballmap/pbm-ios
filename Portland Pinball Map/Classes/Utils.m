//
//  Utils.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 9/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(BOOL) stringIsBlank:(NSString *)string
{
	for (int i = 0; i < [string length]; i++)
	{
		if(![[string substringWithRange:NSMakeRange(i,1)] isEqualToString:@" "]) return NO;
	}
	return YES;
}

+(void)sendErrorReport:(NSString*)string
{
	UIDevice *device = [UIDevice currentDevice];
	NSString *newFormat = [[NSString alloc] initWithFormat:@"%@ | 2.0.0 | %@ iOS %@",string,device.model,device.systemVersion];
	NSString *erstr  = [Utils urlencode:newFormat];
	
	
	NSString *urlstr = [[NSString alloc] initWithFormat:@"http://portlandpinballmap.com/iphone.html?error=%@",erstr];
	NSURL    *url = [[NSURL alloc] initWithString:urlstr];
	NSError  *error;
	NSString *test = [NSString stringWithContentsOfURL:url
											  encoding:NSUTF8StringEncoding
												 error:&error];
	
	//NSLog(@"Error returned: %@",urlstr);
	//NSLog(@"Error returned: %@",error);
	//NSLog(@"output: %@",test);
	
	[newFormat release];
	[urlstr release];
	[url release];
}

+(NSString *) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*",@"'",@" ",@"|", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A",@"",@"%20",@"%7C", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	
    return out;
}

@end
