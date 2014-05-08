//
//  MachinePickingView.h
//  Pinball
//
//  Created by Frank Michael on 4/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickingDelegate;

@interface MachinePickingView : UITableViewController

@property (nonatomic,assign) id delegate; // PickingDelegate
@property (nonatomic,assign) NSArray *pickedMachines;
@property (nonatomic,assign) BOOL canPickMultiple;

@end


@protocol PickingDelegate <NSObject>

- (void)pickedMachines:(NSArray *)machines;

@end