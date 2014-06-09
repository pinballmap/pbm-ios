//
//  LocationsView.h
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsView : UITableViewController

@property (nonatomic)BOOL isSelecting;
@property (nonatomic)id selectingViewController;

- (IBAction)filterResults:(id)sender;


@end
