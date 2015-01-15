//
//  RegionsView.h
//  PinballMap
//
//  Created by Frank Michael on 4/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegionSelectionDelegate;
@interface RegionsView : UITableViewController

@property (nonatomic) id <RegionSelectionDelegate> delegate;
@property (nonatomic) BOOL isSelecting;

@end


@protocol RegionSelectionDelegate <NSObject>

- (void)didSelectNewRegion:(Region *)region;

@end