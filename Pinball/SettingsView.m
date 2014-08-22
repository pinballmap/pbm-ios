//
//  SettingsView.m
//  PinballMap
//
//  Created by Frank Michael on 4/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "SettingsView.h"
#import "UIAlertView+Application.h"

@import MessageUI;

@interface SettingsView () <MFMailComposeViewControllerDelegate> {
    IBOutlet UILabel *regionLabel;
}
- (void)updateRegion;
- (IBAction)sendFeedback:(id)sender;

@end

@implementation SettingsView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRegion) name:@"RegionUpdate" object:nil];
    [self updateRegion];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateRegion{
    regionLabel.text = [[[PinballMapManager sharedInstance] currentRegion] fullName];
}
#pragma mark - Class Actions
- (IBAction)sendFeedback:(id)sender{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setToRecipients:@[@"pinballmap@outlook.com"]];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }else{
        [UIAlertView simpleApplicationAlertWithMessage:@"Your device is not setup to send an email." cancelButton:@"Ok"];
    }
}
#pragma mark - Mail Compose Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result == MFMailComposeResultFailed){
        [UIAlertView simpleApplicationAlertWithMessage:@"Message failed to send." cancelButton:@"Ok"];
    }else if (result == MFMailComposeResultSent){
        [UIAlertView simpleApplicationAlertWithMessage:@"Message sent!" cancelButton:@"Ok"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

@end
