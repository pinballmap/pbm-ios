//
//  MachineViewController.h
//  Portland Pinball Map
//
//  Created By Isaac Ruiz on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MachineFilterView.h"
#import "BlackTableViewController.h"
#import <UIKit/UIKit.h>



@interface MachineViewController : BlackTableViewController {
		
	NSMutableDictionary *sortedMachines;
	NSArray             *keys;
	
	MachineFilterView *machineFilter;
	
}

@property (nonatomic,retain) NSMutableDictionary *sortedMachines;
@property (nonatomic,retain) NSArray             *keys;
@property (nonatomic,retain) MachineFilterView   *machineFilter;


@end
