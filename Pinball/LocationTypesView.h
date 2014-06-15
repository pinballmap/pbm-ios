//
//  LocationTypesView.h
//  PinballMap
//
//  Created by Frank Michael on 5/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationType.h"

@protocol LocationTypeDelegate;
@interface LocationTypesView : UITableViewController

@property (nonatomic) id <LocationTypeDelegate> delegate;

@end


@protocol LocationTypeDelegate <NSObject>

- (void)pickedType:(LocationType *)type;

@end