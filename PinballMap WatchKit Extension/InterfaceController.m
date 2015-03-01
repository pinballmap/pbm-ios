//
//  InterfaceController.m
//  PinballMap WatchKit Extension
//
//  Created by Frank Michael on 2/26/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController()

@property (weak) IBOutlet WKInterfaceTable *menuTable;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    NSArray *menuItems = @[
                           @{@"name":@"Nearest",@"icon":@"849-radar"},
                           @{@"name":@"Recent",@"icon":@"728-clock"},
                           @{@"name":@"Events",@"icon":@"851-calendar"}
                           ];
    [self.menuTable setNumberOfRows:menuItems.count withRowType:@"MainMenuRow"];
    for (int idx=0; idx <= menuItems.count-1; idx++) {
        NSDictionary *menuItem = menuItems[idx];
        MainMenuRow *row = [self.menuTable rowControllerAtIndex:idx];
        [row.menuItemTitle setText:menuItem[@"name"]];
        [row.menuItemImage setImageNamed:menuItem[@"icon"]];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}
- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    if (rowIndex == 0){
        // Nearest Location
    }else if (rowIndex == 1){
        // Recent Machines
        [self pushControllerWithName:@"RecentsController" context:@"Recents"];
    }else if (rowIndex == 2){
        // Upcoming Events
        [self pushControllerWithName:@"EventsController" context:@"Events"];
    }
}

@end


@implementation MainMenuRow


@end


