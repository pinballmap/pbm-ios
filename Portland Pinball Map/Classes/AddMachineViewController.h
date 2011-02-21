//
//  AddMachineViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 4/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LocationObject.h"
@class LocationObject;

@interface AddMachineViewController : UIViewController <UIPickerViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{
	UITextField *textfield;
	UIPickerView *picker;
	UIButton     *submitButton;
	UIButton     *returnButton;
	NSMutableArray *machineArray;
	NSString     *selected_machine_id;
	
	UIActivityIndicatorView *loaderIcon;
	
	LocationObject *location;
	NSString *locationName;
	NSString *locationId;
}
@property (nonatomic,retain) NSString *selected_machine_id;
@property (nonatomic,retain) LocationObject *location;
@property (nonatomic,retain) NSString *locationName;
@property (nonatomic,retain) NSString *locationId;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loaderIcon;
@property (nonatomic,retain) IBOutlet UIButton *submitButton;
@property (nonatomic,retain) IBOutlet UIButton *returnButton;
@property (nonatomic,retain) IBOutlet UITextField *textfield;
@property (nonatomic,retain) IBOutlet UIPickerView *picker;

-(IBAction)onReturnTap:(id)sender;
-(IBAction)onSumbitTap:(id)sender;
-(void)addMachineFromTextfield;
-(void)addMachineWithURL:(NSString*)urlstr;
-(NSString*)stripString:(NSString*)string;

@end
