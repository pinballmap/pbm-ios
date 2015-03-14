//
//  EventInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 2/26/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "EventInterfaceController.h"
#import "Event.h"
#import "Event+CellHelpers.h"
#import "NSDate+DateFormatting.h"

@interface EventInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *eventTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *eventDate;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *eventDesc;

@end


@implementation EventInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    Event *event = (Event *)context;
    [self.eventTitle setAttributedText:event.eventTitle];
    [self.eventDate setText:[event.startDate monthDayYearPretty:true]];
    [self.eventDesc setText:event.eventDescription];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



