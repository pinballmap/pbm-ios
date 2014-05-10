//
//  FMSDrawer.h
//  FMSDrawer
//
//  Created by Frank Michael on 1/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawerDataSource;
@protocol DrawerDelegate;

@interface FMSDrawer : UIView <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UINavigationController *parentView;
@property (nonatomic,strong) id <DrawerDataSource> dataSource;
@property (nonatomic,strong) id <DrawerDelegate> delegate;
+ (id)sharedInstance;
- (void)reloadTable;
- (BOOL)isVisible;
- (UIBarButtonItem *)navigationButton;
- (IBAction)drawerDidDrag:(UIPanGestureRecognizer *)sender;
@end

@protocol DrawerDataSource <NSObject>
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsForSection:(NSInteger)section;
- (NSString *)titleForRow:(NSIndexPath *)path;
@optional
- (NSString *)titleForHeaderInSection:(NSInteger)section;
@end

@protocol DrawerDelegate <NSObject>
- (void)selectedItemAtIndexPath:(NSIndexPath *)path;
@end