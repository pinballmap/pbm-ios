//
//  UIAlertView+Application.h
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Application)

+ (UIAlertView *)applicationAlertWithMessage:(NSString *)message delegate:(id)delegate cancelButton:(NSString *)cancelTitle otherButtons:(NSString*)otherTitles, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)simpleApplicationAlertWithMessage:(NSString *)message cancelButton:(NSString *)cancelTitle;

@end
