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

@interface PinballTabController ()

@property (nonatomic) UIAlertView *updatingAlert;
@property (nonatomic) UIView *motdAlert;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingProgress:) name:@"UpdatingProgress" object:nil];
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
    }else{
        [self showMessageOfDay];
    }
}
- (void)updateTabInfo{
    [self.updatingAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self showMessageOfDay];
}
- (void)showMessageOfDay{
    if ([[PinballMapManager sharedInstance] currentRegion] && [[PinballMapManager sharedInstance] shouldShowMessageOfDay]){
        [[PinballMapManager sharedInstance] refreshBasicRegionData:^(NSDictionary *status) {
            if (status[@"errors"]){
                NSString *errors;
                if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                    errors = [status[@"errors"] componentsJoinedByString:@","];
                }else{
                    errors = status[@"errors"];
                }
                [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
            }else{
                [[PinballMapManager sharedInstance] showedMessageOfDay];
                
                NSString *message = status[@"region"][@"motd"];
                if (![message isKindOfClass:[NSNull class]] && message.length > 0){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIColor *pinkColor = [UIColor colorWithRed:1.0f green:0.0f blue:146.0f/255.0f alpha:1];
                        
                        self.motdAlert = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-self.tabBar.frame.size.height-50, self.view.frame.size.width, 50)];
                        self.motdAlert.backgroundColor = pinkColor;
                        UILabel *motdLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.motdAlert.frame.size.width-20, self.motdAlert.frame.size.height)];
                        motdLabel.font = [UIFont systemFontOfSize:14];
                        motdLabel.textColor = [UIColor whiteColor];
                        motdLabel.text = status[@"region"][@"motd"];
                        motdLabel.numberOfLines = 0;
                        [self.motdAlert addSubview:motdLabel];
                        CGRect stringSize = [motdLabel.text boundingRectWithSize:CGSizeMake(motdLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
                        motdLabel.frame = CGRectMake(10, 0, self.motdAlert.frame.size.width-20, stringSize.size.height);
                        
                        motdLabel.userInteractionEnabled = YES;
                        UITapGestureRecognizer *view = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewMessageOfDay:)];
                        view.numberOfTapsRequired = 1;
                        [motdLabel addGestureRecognizer:view];
                        self.motdAlert.alpha = 0.0;
                        [self.view.window.rootViewController.view addSubview:self.motdAlert];
                        [UIView animateWithDuration:.5 animations:^{
                            self.motdAlert.alpha = 1.0;
                        }completion:^(BOOL finished) {
                            int64_t delayInSeconds = 3;
                            
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                            
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [UIView animateWithDuration:.5 animations:^{
                                    self.motdAlert.alpha = 0.0;
                                }completion:^(BOOL finished) {
                                    [self.motdAlert removeFromSuperview];
                                }];
                            });
                        }];
                    });
                    NSLog(@"%@",status);
                }
            }
        }];
    }
}
- (void)updatingRegion{
    self.updatingAlert = [UIAlertView applicationAlertWithMessage:@"Updating Region" delegate:nil cancelButton:nil otherButtons:nil, nil];
    [self.updatingAlert show];
}
- (void)updatingProgress:(NSNotification *)note{
    NSDictionary *progress = note.object;
    self.updatingAlert.message = [NSString stringWithFormat:@"%@ of %@ completed",progress[@"completed"],progress[@"total"]];
}
- (IBAction)viewMessageOfDay:(id)sender{
    [self.motdAlert removeFromSuperview];
    self.motdAlert = nil;
    [self setSelectedViewController:[self.viewControllers lastObject]];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
