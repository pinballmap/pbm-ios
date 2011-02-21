//
//  AboutViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 12/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {
	UIButton *drewButton;
	UIButton *ryanButton;
	UIButton *scottButton;
	UIButton *isaacButton;
	UIButton *ppmButton;
	
	WebViewController *webview;
}

@property (nonatomic,retain) WebViewController *webview;
@property (nonatomic,retain) IBOutlet UIButton *ppmButton;
@property (nonatomic,retain) IBOutlet UIButton *drewButton;
@property (nonatomic,retain) IBOutlet UIButton *ryanButton;
@property (nonatomic,retain) IBOutlet UIButton *scottButton;
@property (nonatomic,retain) IBOutlet UIButton *isaacButton;

-(IBAction)ppmButtonPress:(id)sender;
-(IBAction)drewButtonPress:(id)sender;
-(IBAction)ryanButtonPress:(id)sender;
-(IBAction)scottButtonPress:(id)sender;
-(IBAction)isaacButtonPress:(id)sender;
-(void)viewURL:(NSString*)url withTitle:(NSString*)string;

@end
