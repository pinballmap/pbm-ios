//
//  PinballTabController.m
//  Pinball
//
//  Created by Frank Michael on 4/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "PinballTabController.h"
#import "UIAlertView+Application.h"

@interface PinballTabController ()
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
    [[[self.viewControllers objectAtIndex:2] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%i",eventCounts]];
}
- (void)updatingRegion{
    [UIAlertView simpleApplicationAlertWithMessage:@"Updating Region" cancelButton:@"Ok"];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
