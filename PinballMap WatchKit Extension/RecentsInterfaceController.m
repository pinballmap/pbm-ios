
//  RecentsInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 2/26/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "RecentsInterfaceController.h"


@interface RecentsInterfaceController()

@property (weak) IBOutlet WKInterfaceTable *recentsTable;

@end


@implementation RecentsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [WKInterfaceController openParentApplication:@{@"action":@"recent_machines"} reply:^(NSDictionary *replyInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error){
                NSString *status = replyInfo[@"status"];
                if ([status isEqualToString:@"ok"]){
                    NSArray *machines = replyInfo[@"body"];
                    
                    [self.recentsTable setNumberOfRows:machines.count withRowType:@"MachineRow"];
                    for (int idx=0; idx <= machines.count-1; idx++) {
                        NSDictionary *recentMachine = machines[idx];
                        MachineRow *row = [self.recentsTable rowControllerAtIndex:idx];
                        [row.locationLabel setText:recentMachine[@"location_name"]];
                        [row.machineLabel setText:recentMachine[@"machine_name"]];
                    }
                }else{
                    // Failed response from parent app.
                }
            }else{
                NSLog(@"%@",error);
            }
        });
    }];
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


@implementation MachineRow


@end


