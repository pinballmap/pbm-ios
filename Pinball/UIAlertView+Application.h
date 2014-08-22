//
//  UIAlertView+Application.h
//
//  Created by Frank Michael Sanchez on 11/5/13.
//  Copyright (c) 2013 Frank Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Application)

+ (UIAlertView *)applicationAlertWithMessage:(NSString *)message delegate:(id)delegate cancelButton:(NSString *)cancelTitle otherButtons:(NSString*)otherTitles, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)simpleApplicationAlertWithMessage:(NSString *)message cancelButton:(NSString *)cancelTitle;

@end
