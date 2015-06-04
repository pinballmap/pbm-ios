//
//  MachineInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 2/27/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "MachineInterfaceController.h"


@interface MachineInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *machineLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *locationLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *locationMap;

@end


@implementation MachineInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    NSDictionary *machineInfo = context;
    
    [self.machineLabel setText:machineInfo[@"machine"][@"name"]];
    [self.locationLabel setText:[NSString stringWithFormat:@"%@, %@",machineInfo[@"location"][@"name"],machineInfo[@"location"][@"city"]]];
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([machineInfo[@"location"][@"lat"] doubleValue], [machineInfo[@"location"][@"lon"] doubleValue]);
    [self.locationMap setRegion:MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.01, 0.01))];
    [self.locationMap addAnnotation:location withPinColor:WKInterfaceMapPinColorRed];
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



