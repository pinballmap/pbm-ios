//
//  NewMachineView.h
//  PinballMap
//
//  Created by Frank Michael on 4/19/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@protocol NewMachineDelegate;
@interface NewMachineLocationView : UITableViewController

@property (nonatomic) id <NewMachineDelegate> delegate;
@property (nonatomic)Location *location;

@end

@protocol NewMachineDelegate <NSObject>
- (void)didAddMachine;
@end
