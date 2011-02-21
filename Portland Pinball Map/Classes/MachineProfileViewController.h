//
//  MachineProfileViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 5/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationObject.h"
#import "MachineObject.h"
#import "MachineFilterView.h"
#import "CommentController.h"
#import "WebViewController.h"
#import <UIKit/UIKit.h>


@interface MachineProfileViewController : UIViewController <UIActionSheetDelegate,UIAlertViewDelegate>
{
	
	UILabel      *machineLabel;
	UILabel      *locationLabel;
	UILabel      *conditionLabel;
	UITextView   *conditionField;
	
	UIButton     *returnButton;
	UIButton     *deleteButton;
	UIButton     *ipdbButton;
	UIButton     *otherLocationsButton;
	UIButton     *updateConditionButton;
	
	MachineFilterView *machineFilter;
	
	WebViewController    *webview;
	
	NSRange dayRange2;
	NSRange monthRange2;
	NSRange yearRange2;
	
	CommentController *commentController;
	
	LocationObject *location;
	MachineObject  *machine;
}
@property (nonatomic,retain) WebViewController        *webview;
@property (nonatomic,retain) LocationObject *location;
@property (nonatomic,retain) MachineObject  *machine;

@property (nonatomic,retain) CommentController *commentController;
@property (nonatomic,retain) MachineFilterView *machineFilter;

@property (nonatomic,retain) IBOutlet UIButton *updateConditionButton;
@property (nonatomic,retain) IBOutlet UIButton *otherLocationsButton;
@property (nonatomic,retain) IBOutlet UILabel  *machineLabel;
@property (nonatomic,retain) IBOutlet UILabel  *locationLabel;
@property (nonatomic,retain) IBOutlet UILabel  *conditionLabel;
@property (nonatomic,retain) IBOutlet UITextView  *conditionField;
@property (nonatomic,retain) IBOutlet UIButton    *returnButton;
@property (nonatomic,retain) IBOutlet UIButton    *ipdbButton;

@property (nonatomic,retain) IBOutlet UIButton *deleteButton;

-(IBAction)onUpdateConditionTap:(id)sender;
-(IBAction)onDeleteTap:(id)sender;
-(IBAction)onReturnTap:(id)sender;
-(IBAction)onIPDBTap:(id)sender;
-(IBAction)onOtherLocationsTap:(id)sender;
-(IBAction) onEditButtonPressed:(id)sender;
-(void)hideControllButtons:(BOOL)doHide;
-(void)removeMachineWithURL:(NSString*)urlstr;
+(NSString *)urlEncodeValue:(NSString *)str;

//-(NSDate *)getDateFromString:(NSString *)dateString;
-(NSString*)formatDateFromString:(NSString*)string;

@end
