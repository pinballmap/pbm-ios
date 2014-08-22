//
//  FMSDrawer.h
//  FMSKit
//
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
- (UIBarButtonItem *)navigationButton;
- (IBAction)drawerDidDrag:(UIPanGestureRecognizer *)sender;
@end

@protocol DrawerDataSource <NSObject>
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsForDrawer:(NSInteger)section;
- (NSString *)titleForDrawerRow:(NSIndexPath *)path;
@optional
- (NSString *)titleForDrawerHeaderInSection:(NSInteger)section;
@end

@protocol DrawerDelegate <NSObject>
- (void)selectedDrawerAtIndexPath:(NSIndexPath *)path;
@end