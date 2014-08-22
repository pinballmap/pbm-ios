//
//  NewMachineScoreView.h
//  PinballMap
//
//  Created by Frank Michael on 5/26/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MachineScore.h"

@protocol ScoreDelegate;
@interface NewMachineScoreView : UITableViewController
@property (nonatomic) id <ScoreDelegate> delegate;

@property (nonatomic) MachineLocation *currentMachine;

@end

@protocol ScoreDelegate <NSObject>

- (void)didAddScore;

@end