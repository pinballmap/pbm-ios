//
//  PPMTableCell.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PPMTableCell : UITableViewCell {
	UILabel *nameLabel;
}

@property (nonatomic,retain) IBOutlet UILabel *nameLabel;


@end
