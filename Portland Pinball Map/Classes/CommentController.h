//
//  CommentController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MachineObject;
@class LocationObject;


@interface CommentController : UIViewController <UITextViewDelegate,UIAlertViewDelegate>
{
	UIButton    *submitButton;
	UIButton    *cancelButton;
	UITextView  *textview;
	
	NSString     *savedConditionText;
	
	MachineObject *machine;
	LocationObject *location;
}

@property (nonatomic,retain) LocationObject *location;
@property (nonatomic,retain) MachineObject *machine;
@property (nonatomic,retain) IBOutlet UIButton *submitButton;
@property (nonatomic,retain) IBOutlet UIButton *cancelButton;
@property (nonatomic,retain) IBOutlet UITextView *textview;

-(IBAction)onSubmitTap:(id)sender;
-(IBAction)onCancelTap:(id)sender;
@end
