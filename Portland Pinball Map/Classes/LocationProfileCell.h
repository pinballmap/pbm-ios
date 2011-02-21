//
//  LocationProfileCell.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LocationProfileCell : UITableViewCell {

	UILabel  *label;
	UILabel  *addressLabel1;
	UILabel  *addressLabel2;
	UILabel  *phoneLabel;
	UILabel  *distanceLabel;
}

@property (nonatomic,retain) IBOutlet UILabel      *distanceLabel;
@property (nonatomic,retain) IBOutlet UILabel      *label;
@property (nonatomic,retain) IBOutlet UILabel      *addressLabel1;
@property (nonatomic,retain) IBOutlet UILabel      *addressLabel2;
@property (nonatomic,retain) IBOutlet UILabel      *phoneLabel;

@end
