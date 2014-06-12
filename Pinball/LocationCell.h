//
//  LocationCell.h
//  Pinball
//
//  Created by Frank Michael on 6/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *locationName;
@property (nonatomic) IBOutlet UILabel *machineCount;
@property (nonatomic) IBOutlet UILabel *locationDetail;

@end
