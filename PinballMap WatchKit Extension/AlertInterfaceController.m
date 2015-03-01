//
//  AlertInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 2/27/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "AlertInterfaceController.h"


@interface AlertInterfaceController()

@property (weak) IBOutlet WKInterfaceLabel *alertLabel;

@end


@implementation AlertInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self.alertLabel setText:context];
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



