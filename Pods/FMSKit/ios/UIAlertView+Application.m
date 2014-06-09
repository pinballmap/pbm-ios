//
//  UIAlertView+Application.m
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "UIAlertView+Application.h"

@implementation UIAlertView (Application)

+ (UIAlertView *)applicationAlertWithMessage:(NSString *)message delegate:(id)delegate cancelButton:(NSString *)cancelTitle otherButtons:(NSString*)otherTitles, ... NS_REQUIRES_NIL_TERMINATION{
    NSString *applicationTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:applicationTitle message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:otherTitles,nil];
    return alertView;
}
+ (void)simpleApplicationAlertWithMessage:(NSString *)message cancelButton:(NSString *)cancelTitle{
    NSString *applicationTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [[[UIAlertView alloc] initWithTitle:applicationTitle message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil] show];
}
@end
