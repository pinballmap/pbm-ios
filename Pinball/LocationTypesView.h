//
//  LocationTypesView.h
//  PinballMap
//
//  Created by Frank Michael on 5/22/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationType.h"

typedef NS_ENUM(NSUInteger, SelectionType) {
    SelectionTypeAll = 0,       // All Location Types
    SelectionTypeRegion         // Only Location Types that have locations attached to him
};

@protocol LocationTypeSelectDelegate;
@interface LocationTypesView : UITableViewController

@property (nonatomic) id <LocationTypeSelectDelegate> delegate;
@property (nonatomic) SelectionType type;

@end


@protocol LocationTypeSelectDelegate <NSObject>

- (void)selectedLocationType:(LocationType *)type;

@end