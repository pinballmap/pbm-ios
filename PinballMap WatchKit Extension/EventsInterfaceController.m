//
//  EventsInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 2/26/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "EventsInterfaceController.h"
#import "CoreDataManager.h"
#import "NSDate+CupertinoYankee.h"
#import "Event.h"
#import "Event+CellHelpers.h"
#import "NSDate+DateFormatting.h"
#import "AppSettings.h"
#import "AlertInterfaceController.h"

@interface EventsInterfaceController()

@property (weak) IBOutlet WKInterfaceTable *eventsTable;
@property (nonatomic) NSString *regionName;
@property (nonatomic) NSMutableArray *events;
@property (nonatomic) BOOL hadError;

@end

@implementation EventsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSDictionary *regionInfo = [AppSettings valueForSetting:AppSettingCurrentRegion];
    self.regionName = regionInfo[@"name"];

    [WKInterfaceController openParentApplication:@{@"action":@"events"} reply:^(NSDictionary *replyInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error){
                NSString *status = replyInfo[@"status"];
                if ([status isEqualToString:@"ok"]){
                    self.events = replyInfo[@"body"];
                    
                    [self.eventsTable setNumberOfRows:self.events.count withRowType:@"EventRow"];
                    for (int idx=0; idx <= self.events.count-1; idx++) {
                        NSDictionary *recentEvent = self.events[idx];
                        EventRow *row = [self.eventsTable rowControllerAtIndex:idx];
                        [row.eventTitle setText:[NSString stringWithFormat:@"%@",recentEvent[@"event_title"]]];
                        [row.eventDate setText:recentEvent[@"event_date"]];
                    }
                } else {
                    self.hadError = true;
                    Alert *apiError = [[Alert alloc] init];
                    apiError.title = @"Error";
                    apiError.body = replyInfo[@"body"];
                    [self presentControllerWithName:@"AlertController" context:apiError];
                }
            }else{
                self.hadError = true;
                Alert *parentError = [[Alert alloc] init];
                parentError.title = @"Error";
                parentError.body = error.localizedDescription;
                [self presentControllerWithName:@"AlertController" context:parentError];
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

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSDictionary *recentEvent = self.events[rowIndex];
    
    [self pushControllerWithName:@"EventController" context:recentEvent[@"event"]];
}

@end

@implementation EventRow

@end

