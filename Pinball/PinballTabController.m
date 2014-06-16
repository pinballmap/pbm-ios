//
//  PinballMapTabController.m
//  PinballMap
//
//  Created by Frank Michael on 4/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "PinballTabController.h"
#import "UIAlertView+Application.h"
#import "RegionsView.h"

@interface PinballTabController () {
    UIAlertView *updatingAlert;
}
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTabInfo) name:@"RegionUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingRegion) name:@"UpdatingRegion" object:nil];
    [self updateTabInfo];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![[PinballMapManager sharedInstance] currentRegion]){
        RegionsView *regions = [self.storyboard instantiateViewControllerWithIdentifier:@"RegionsView"];
        regions.isSelecting = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:regions];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (void)updateTabInfo{
    Region *currentRegion = [[PinballMapManager sharedInstance] currentRegion];

    [[[self.viewControllers objectAtIndex:0] tabBarItem] setTitle:currentRegion.fullName];
    
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
