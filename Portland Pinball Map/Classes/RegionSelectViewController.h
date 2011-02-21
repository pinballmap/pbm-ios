//
//  RegionSelectViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlackTableViewController.h"
#import "RequestPage.h"


@interface RegionSelectViewController : BlackTableViewController
{
	NSArray *regionArray;
	RequestPage *requestPage;
}

@property (nonatomic,retain) RequestPage *requestPage;
@property (nonatomic,retain) NSArray *regionArray;
@end
