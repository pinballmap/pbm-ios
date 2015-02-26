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

NSString * const apiRootURL = @"http://pinballmap.com/";
NSString * const appGroup = @"group.net.isaacruiz.ppm";

@interface EventsInterfaceController()

@property (weak) IBOutlet WKInterfaceTable *eventsTable;
@property (nonatomic) NSString *regionName;
@property (nonatomic) NSMutableArray *events;

@end


@implementation EventsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    NSDictionary *regionInfo = [[EventsInterfaceController userDefaultsForApp] objectForKey:@"CurrentRegion"];
    self.regionName = regionInfo[@"name"];

    self.events = [[NSMutableArray alloc] init];
    NSFetchRequest *eventsFetch = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    eventsFetch.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND startDate >= %@",self.regionName,[[NSDate date] endOfDay]];
    eventsFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:true]];
    eventsFetch.fetchLimit = 5;
    [self.events removeAllObjects];
    [self.events addObjectsFromArray:[[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:eventsFetch error:nil]];
    
    [self.eventsTable setNumberOfRows:self.events.count withRowType:@"EventRow"];
    
    for (int idx=0; idx <= self.events.count-1; idx++) {
        Event *event = [self.events objectAtIndex:idx];
        EventRow *row = [self.eventsTable rowControllerAtIndex:idx];
        [row.eventTitle setAttributedText:event.eventTitle];
        [row.eventDate setText:[event.startDate monthDayYearPretty:true]];
    }
    

}
+ (NSUserDefaults *)userDefaultsForApp{
    return [[NSUserDefaults alloc] initWithSuiteName:appGroup];
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

@implementation EventRow


@end

