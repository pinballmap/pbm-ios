//
//  PinballTabController.m
//  Pinball
//
//  Created by Frank Michael on 4/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "PinballTabController.h"
#import "UIAlertView+Application.h"

@interface PinballTabController () {
    UIAlertView *updatingAlert;
}
- (void)updateEventBadge;
- (void)updatingRegion;
@end

@implementation PinballTabController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventBadge) name:@"RegionUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingRegion) name:@"UpdatingRegion" object:nil];
    [self updateEventBadge];
}
- (void)updateEventBadge{
    NSInteger eventCounts = [[[[PinballManager sharedInstance] currentRegion] events] count];
    if (eventCounts > 0){
        [[[self.viewControllers objectAtIndex:2] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%li",(long)eventCounts]];
    }
    [updatingAlert dismissWithClickedButtonIndex:0 animated:YES];
}
- (void)updatingRegion{
    updatingAlert = [UIAlertView applicationAlertWithMessage:@"Updating Region" delegate:nil cancelButton:@"Ok" otherButtons:nil, nil];
    [updatingAlert show];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
