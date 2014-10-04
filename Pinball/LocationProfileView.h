//
//  LocationProfileView.h
//  PinballMap
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinballModels.h"

@interface LocationProfileView : UITableViewController

@property (nonatomic) Location *currentLocation;
@property (nonatomic) BOOL showMapSnapshot;

- (IBAction)editLocation:(id)sender;

@end
