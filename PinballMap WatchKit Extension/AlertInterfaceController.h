//
//  AlertInterfaceController.h
//  PinballMap
//
//  Created by Frank Michael on 2/27/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface AlertInterfaceController : WKInterfaceController

@end

@interface Alert : NSObject

@property (nonatomic) NSString *alertTitle;
@property (nonatomic) NSString *alertBody;

@end