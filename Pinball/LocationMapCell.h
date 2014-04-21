//
//  LocationMapCell.h
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationMapCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *mapImage;
@property (nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end
