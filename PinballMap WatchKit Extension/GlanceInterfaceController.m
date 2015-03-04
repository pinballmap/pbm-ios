//
//  GlanceInterfaceController.m
//  PinballMap
//
//  Created by Frank Michael on 3/3/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "GlanceInterfaceController.h"


@interface GlanceInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *locationLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *locationDistance;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *addressLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *locationMap;

@end


@implementation GlanceInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [WKInterfaceController openParentApplication:@{@"action":@"nearby_location"} reply:^(NSDictionary *replyInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error){
                NSString *status = replyInfo[@"status"];
                if ([status isEqualToString:@"ok"]){
                    NSDictionary *location = replyInfo[@"body"];
                    
                    [self.locationLabel setText:@"Back in your head by Tegan and Sara"];//location[@"name"]];
                    [self.locationLabel setTextColor:[UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1.0]];
                    [self.addressLabel setText:[NSString stringWithFormat:@"%@, %@",location[@"street"],location[@"city"]]];
                    
                    if (location[@"distance"]){
                        NSNumber *num = location[@"distance"];
                        [self.locationDistance setText:[NSString stringWithFormat:@"%.02f miles",num.doubleValue]];
                    }

                    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([location[@"lat"] doubleValue], [location[@"lon"] doubleValue]);
                    [self.locationMap setRegion:MKCoordinateRegionMake(locationCoordinate, MKCoordinateSpanMake(0.01, 0.01))];
                    [self.locationMap addAnnotation:locationCoordinate withPinColor:WKInterfaceMapPinColorRed];
                    [self.locationMap setHidden:false];

                }else{

                }
            }else{

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



