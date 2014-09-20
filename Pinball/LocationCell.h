//
//  LocationCell.h
//  PinballMap
//
//  Created by Frank Michael on 6/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (weak) IBOutlet UILabel *locationName;
@property (weak) IBOutlet UILabel *machineCount;
@property (weak) IBOutlet UILabel *locationDetail;

@end
