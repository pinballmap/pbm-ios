//
//  MachineManufacturerView.h
//  PinballMap
//
//  Created by Frank Michael on 12/28/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManufacturerSelectionDelegate;

@interface MachineManufacturerView : UITableViewController

@property (nonatomic) id<ManufacturerSelectionDelegate> delegate;

@end

@protocol ManufacturerSelectionDelegate <NSObject>

- (void)selectedManufacturer:(NSString *)manufacturer;

@end