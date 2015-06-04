//
//  NearestInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 3/3/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "NearestInterfaceController.h"
#import "AlertInterfaceController.h"

@interface NearestInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *locationLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *addressLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *locationDistance;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *locationMap;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *machineCount;
@property (nonatomic) BOOL hadError;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *callButton;
@property (weak, nonatomic) IBOutlet WKInterfaceSeparator *separtorTwo;

@end


@implementation NearestInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self.locationLabel setText:@"Finding Location..."];
    [self.addressLabel setText:nil];
    [self.locationDistance setText:nil];
    [self.machineCount setText:nil];
    [self.locationMap setHidden:true];
    [self.callButton setHidden:true];
    [self.separtorTwo setHidden:true];
    
    [WKInterfaceController openParentApplication:@{@"action":@"nearby_location"} reply:^(NSDictionary *replyInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error){
                NSString *status = replyInfo[@"status"];
                if ([status isEqualToString:@"ok"]){
                    NSDictionary *location = replyInfo[@"body"];
                    
                    [self.locationLabel setText:location[@"name"]];
                    [self.addressLabel setText:[NSString stringWithFormat:@"%@, %@",location[@"street"],location[@"city"]]];
                    
                    if (location[@"distance"]){
                        NSNumber *num = location[@"distance"];
                        [self.locationDistance setText:[NSString stringWithFormat:@"%.02f miles",num.doubleValue]];
                    }
                    NSArray *machineNames = location[@"machine_names"];
                    if (machineNames && machineNames.count > 0){
                        [self.machineCount setText:[NSString stringWithFormat:@"Machines: %lu",(unsigned long)machineNames.count]];
                    }else{
                        [self.machineCount setText:@"No Machines"];
                    }
                    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([location[@"lat"] doubleValue], [location[@"lon"] doubleValue]);
                    [self.locationMap setRegion:MKCoordinateRegionMake(locationCoordinate, MKCoordinateSpanMake(0.01, 0.01))];
                    [self.locationMap addAnnotation:locationCoordinate withPinColor:WKInterfaceMapPinColorRed];
                    [self.locationMap setHidden:false];
                    [self.callButton setHidden:false];
                    [self.separtorTwo setHidden:false];
                }else{
                    // Failed API response from parent app.
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

@end



