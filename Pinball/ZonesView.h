//
//  ZonesView.h
//  PinballMap
//
//  Created by Frank Michael on 6/16/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zone.h"

@protocol ZoneSelectDelegate;

@interface ZonesView : UITableViewController

@property (nonatomic) id <ZoneSelectDelegate> delegate;

@end

@protocol ZoneSelectDelegate <NSObject>

- (void)selectedZone:(Zone *)zone;

@end