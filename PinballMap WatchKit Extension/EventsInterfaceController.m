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

NSString * const apiRootURL = @"http://pinballmap.com/";

@interface EventsInterfaceController()

@property (weak) IBOutlet WKInterfaceTable *eventsTable;
@property (nonatomic) NSString *regionName;
@property (nonatomic) NSMutableArray *events;
@property (nonatomic) BOOL hadError;

@end


@implementation EventsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
    NSDictionary *regionInfo = [AppSettings valueForSetting:AppSettingCurrentRegion];
    self.regionName = regionInfo[@"name"];

    self.events = [[NSMutableArray alloc] init];
    NSFetchRequest *eventsFetch = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    eventsFetch.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND startDate >= %@",self.regionName,[[NSDate date] endOfDay]];
    eventsFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:true]];
    eventsFetch.fetchLimit = 5;
    [self.events removeAllObjects];
    [self.events addObjectsFromArray:[[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:eventsFetch error:nil]];
    
    if (self.events.count > 0){
        [self.eventsTable setNumberOfRows:self.events.count withRowType:@"EventRow"];
        
        for (int idx=0; idx <= self.events.count-1; idx++) {
            Event *event = [self.events objectAtIndex:idx];
            EventRow *row = [self.eventsTable rowControllerAtIndex:idx];
            [row.eventTitle setAttributedText:event.eventTitle];
            [row.eventDate setText:[event.startDate monthDayYearPretty:true]];
        }
    }else{
        Alert *noEventsAlert = [[Alert alloc] init];
        noEventsAlert.title = @"No Events";
        noEventsAlert.body = @"No Events are upcoming for this region";
        self.hadError = true;
        [self presentControllerWithName:@"AlertController" context:noEventsAlert];
    }
    

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
    Event *event = self.events[rowIndex];
    [self pushControllerWithName:@"EventController" context:event];
}

@end

@implementation EventRow


@end

