//
//  ZonesViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationFilterView.h"
#import "BlackTableViewController.h"
#import <UIKit/UIKit.h>


@interface ZonesViewController : BlackTableViewController {
	NSDictionary *zones;
	NSArray      *titles;
	
	LocationFilterView *locationFilter;
	
}

@property (nonatomic,retain) NSDictionary *zones;
@property (nonatomic,retain) NSArray      *titles;
@property (nonatomic,retain) LocationFilterView *locationFilter;

@end
