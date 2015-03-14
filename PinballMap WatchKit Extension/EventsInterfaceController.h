//
//  EventsInterfaceController.h
//  PinballMap
//
//  Created by Frank Michael on 2/26/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface EventsInterfaceController : WKInterfaceController

@end


@interface EventRow : NSObject

@property (nonatomic) IBOutlet WKInterfaceLabel *eventTitle;
@property (nonatomic) IBOutlet WKInterfaceLabel *eventDate;

@end