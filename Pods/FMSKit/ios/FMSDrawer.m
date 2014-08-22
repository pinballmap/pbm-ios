//
//  FMSDrawer.m
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "FMSDrawer.h"

@interface FMSDrawer () <UITableViewDataSource,UITableViewDelegate>{
    UITableView *mainTableView;
    BOOL isVisible;
}
- (IBAction)showDrawer:(id)sender;
@end

#define DrawerWidthiPhone 270
#define DrawerWidthiPad 300


@implementation FMSDrawer
+ (id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p,^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
- (id)initWithFrame:(CGRect)frame{
    if ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound){
        self = [super initWithFrame:CGRectMake(0, 20, DrawerWidthiPad, 748)];
    }else{
        self = [super initWithFrame:CGRectMake(0, 10, DrawerWidthiPhone, 568)];
    }
    if (self) {
        isVisible = NO;
        mainTableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStyleGrouped];
        mainTableView.frame = CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, CGRectGetWidth(mainTableView.frame)-10, CGRectGetHeight(mainTableView.frame));
        [mainTableView setShowsHorizontalScrollIndicator:NO];
        [mainTableView setShowsVerticalScrollIndicator:NO];
        [mainTableView setDelegate:self];
        [mainTableView setDataSource:self];
        [self addSubview:mainTableView];
    
    }
    return self;
}
- (void)reloadTable{
    [mainTableView reloadData];
}
- (UIBarButtonItem *)navigationButton{
    UIBarButtonItem *leftBttn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"259-list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showDrawer:)];
    return leftBttn;
}
- (void)setParentView:(UINavigationController *)parentView{
    UIPanGestureRecognizer *swipeRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawerDidDrag:)];
    swipeRight.delegate = self;
    _parentView = parentView;
    [_parentView.view addGestureRecognizer:swipeRight];
    [_parentView.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_parentView.view insertSubview:self atIndex:0];
}
- (IBAction)showDrawer:(id)sender{
    if (!isVisible && ![sender isKindOfClass:[UIApplication class]]){
        [UIView animateWithDuration:.5 animations:^{
            for (UIView *subView in _parentView.view.subviews){
                if (![subView isKindOfClass:[self class]]){
                    [subView setFrame:CGRectMake(subView.frame.origin.x+self.frame.size.width, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                }
            }
        }];
        isVisible = YES;
    }else if (isVisible){
        [UIView animateWithDuration:.5 animations:^{
            [_parentView.visibleViewController.view setFrame:CGRectMake(0, _parentView.visibleViewController.view.frame.origin.y, _parentView.visibleViewController.view.frame.size.width, _parentView.visibleViewController.view.frame.size.height)];
            for (UIView *subView in _parentView.view.subviews){
                if (![subView isKindOfClass:[self class]]){
                    [subView setFrame:CGRectMake(0, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                }
            }
        }];
        isVisible = NO;
    }
}
- (IBAction)drawerDidDrag:(UIPanGestureRecognizer *)sender{         // Handles when the user drags the drawer open or closed.
    UINavigationController *navController = _parentView;
    CGPoint translation = [sender translationInView:navController.view];
    
    if (navController.viewControllers.count == 1){
        if (translation.x > 0){     //Moving right
            CGRect newFrame = sender.view.frame;
            newFrame.origin.x += translation.x;
            if ([sender velocityInView:navController.view].x >= 2000){  // User swiped the drawer open
                [UIView animateWithDuration:.2 animations:^{
                    for (UIView *subView in navController.view.subviews){
                        if (![subView isKindOfClass:[self class]]){
                            [subView setFrame:CGRectMake(self.frame.size.width, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                        }
                    }
                }completion:^(BOOL finished) {
                    isVisible = YES;
                }];
            }else if (sender.state == UIGestureRecognizerStateEnded){   // User lifed their finger
                if (newFrame.origin.x <= 160 && newFrame.origin.x > 0){ // User did not pan enough to fully show the drawer.
                    [UIView animateWithDuration:.2 animations:^{
                        for (UIView *subView in navController.view.subviews){
                            if (![subView isKindOfClass:[self class]]){
                                [subView setFrame:CGRectMake(0, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                            }
                        }
                    }completion:^(BOOL finished) {
                        isVisible = NO;
                    }];
                }else{  // The users pan was large enought to show the drawer.
                    [UIView animateWithDuration:.2 animations:^{
                        for (UIView *subView in navController.view.subviews){
                            if (![subView isKindOfClass:[self class]]){
                                [subView setFrame:CGRectMake(self.frame.size.width, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                            }
                        }
                    }completion:^(BOOL finished) {
                        isVisible = YES;
                    }];
                }
            }else if (translation.x <= self.frame.size.width && translation.x >= 0){    // Track and move everything to the users finger.
                for (UIView *subView in navController.view.subviews){
                    if (![subView isKindOfClass:[self class]]){
                        [subView setFrame:CGRectMake(newFrame.origin.x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                    }
                }
            }
        }else if (translation.x < 0 && isVisible){   //Moving Left
            CGRect newFrame = CGRectMake(270, 0, 0, 0); // Whatever the width of the drawer is.
            newFrame.origin.x += translation.x;
            if (newFrame.origin.x >= 10 && sender.state == UIGestureRecognizerStateChanged){    // Moving back to the left.
                for (UIView *subView in navController.view.subviews){
                    if (![subView isKindOfClass:[self class]]){
                        [subView setFrame:CGRectMake(newFrame.origin.x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                    }
                }
            }else if (sender.state == UIGestureRecognizerStateEnded || newFrame.origin.x < 10){ // Either user lifted finger or space left is less than 10
                [UIView animateWithDuration:.4 animations:^{
                    for (UIView *subView in navController.view.subviews){
                        if (![subView isKindOfClass:[self class]]){
                            [subView setFrame:CGRectMake(0, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height)];
                        }
                    }
                }completion:^(BOOL finished) {
                    isVisible = NO;
                }];
            }
        }
    }
}
#pragma mark - TableView Datasource/Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataSource numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataSource numberOfRowsForDrawer:section];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_dataSource titleForDrawerHeaderInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [_dataSource titleForDrawerRow:indexPath];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate selectedDrawerAtIndexPath:indexPath];
    [self showDrawer:Nil];
}



@end
