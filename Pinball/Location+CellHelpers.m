//
//  Location+CellHelpers.m
//  Pinball
//
//  Created by Frank Michael on 5/1/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Location+CellHelpers.h"

@implementation Location (CellHelpers)

- (NSString *)fullAddress{
    return [NSString stringWithFormat:@"%@,\n%@,\n%@",self.street,self.city,self.state];
}
- (void)saveMapShot:(UIImage *)snapshot{
    NSArray *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = caches[0];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:snapshot];
    NSString *fileName = [self.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    [data writeToFile:[NSString stringWithFormat:@"%@/%@.mapsnapshot",cacheDirectory,fileName] atomically:YES];
    NSLog(@"%@",caches);
}
- (UIImage *)mapShot{
    NSArray *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = caches[0];
    NSString *fileName = [self.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.mapsnapshot",cacheDirectory,fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
        UIImage *image = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:imagePath]];
        return image;
    }
    return nil;
}
@end
