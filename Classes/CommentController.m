#import "Utils.h"
#import "Machine.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "CommentController.h"

@implementation CommentController
@synthesize submitButton, cancelButton, textview, locationMachineXref;

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:locationMachineXref.machine.name];
	[textview setText:locationMachineXref.condition];
	[textview becomeFirstResponder];
    
	[super viewWillAppear:animated];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    savedConditionText = textview.text;
}

- (IBAction)onSubmitTap:(id)sender {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	UIApplication* app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];
	
	NSString *encodedCondition = [Utils urlEncode:([textview.text isEqual:@""]) ? @" " : textview.text];
	
	NSString *urlstr = [[NSString alloc] initWithFormat:@"%@location_no=%@&machine_no=%@&condition=%@",
						appDelegate.rootURL,
						locationMachineXref.location.idNumber,
                        locationMachineXref.machine.idNumber,
						encodedCondition];
	NSURL *url = [[NSURL alloc] initWithString:urlstr];
	NSError *error;
	NSString *test = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
	NSRange range = [test rangeOfString:@"success"];
	if(range.length > 0) {
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd"];
		
		[locationMachineXref setConditionDate:[NSDate date]];
		[locationMachineXref setCondition:textview.text];
        
		[app setNetworkActivityIndicatorVisible:NO];
		
		[self.navigationController popViewControllerAnimated:YES];
	} else  {
		UIAlertView *alert2 = [[UIAlertView alloc]
							   initWithTitle:@"Sorry"
							   message:@"Machine condition could not be updated at this time, please try again later."
							   delegate:nil
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
		[alert2 show];
		[app setNetworkActivityIndicatorVisible:NO];
	}
	
    savedConditionText = nil;
}
	
- (IBAction)onCancelTap:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	[textview resignFirstResponder];
	[super viewDidDisappear:animated];
}

@end