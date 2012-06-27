#import "Portland_Pinball_MapAppDelegate.h"
#import "PBMViewController.h"

@implementation PBMViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (appDelegate.isPad) {
        return YES;
    } else {
        return [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown;
    }    
}

@end