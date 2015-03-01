
//  RecentsInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 2/26/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "RecentsInterfaceController.h"


@interface RecentsInterfaceController()

@property (weak) IBOutlet WKInterfaceTable *recentsTable;
@property (nonatomic) NSMutableArray *machines;
@property (nonatomic) BOOL hadError;

@end


@implementation RecentsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.machines = [[NSMutableArray alloc] init];
    // Configure interface objects here.
    [WKInterfaceController openParentApplication:@{@"action":@"recent_machines"} reply:^(NSDictionary *replyInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error){
                NSString *status = replyInfo[@"status"];
                if ([status isEqualToString:@"ok"]){
                    self.machines = replyInfo[@"body"];
                    
                    [self.recentsTable setNumberOfRows:self.machines.count withRowType:@"MachineRow"];
                    for (int idx=0; idx <= self.machines.count-1; idx++) {
                        NSDictionary *recentMachine = self.machines[idx];
                        MachineRow *row = [self.recentsTable rowControllerAtIndex:idx];
                        [row.locationLabel setText:[NSString stringWithFormat:@"%@, %@",recentMachine[@"location_machine_xref"][@"location"][@"name"],recentMachine[@"location_machine_xref"][@"location"][@"city"]]];
                        [row.machineLabel setText:recentMachine[@"machine_name"]];
                    }
                }else{
                    // Failed response from parent app.
                    self.hadError = true;
                    [self presentControllerWithName:@"AlertController" context:replyInfo[@"body"]];
                }
            }else{
                self.hadError = true;
                [self presentControllerWithName:@"AlertController" context:error.localizedDescription];
            }
        });
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    if (self.hadError){
        self.hadError = false;
        [self popToRootController];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    NSDictionary *recentMachine = self.machines[rowIndex];
    
    [self pushControllerWithName:@"MachineController" context:recentMachine[@"location_machine_xref"]];
    
}

@end


@implementation MachineRow


@end


