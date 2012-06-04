#import "CommentController.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "Utils.h"

@implementation CommentController
@synthesize submitButton, cancelButton, textview, machine, location;

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:machine.name];
	[textview setText:machine.condition];
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
						location.idNumber,
						machine.idNumber,
						encodedCondition];
	NSURL *url = [[NSURL alloc] initWithString:urlstr];
	NSError *error;
	NSString *test = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
	NSRange range = [test rangeOfString:@"success"];
	if(range.length > 0) {
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd"];
		
		[machine setConditionDate:[inputFormatter stringFromDate:[NSDate date]]];
		[machine setCondition:textview.text];
        
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

- (void)viewDidUnload {
	self.textview = nil;
	self.submitButton = nil;
	self.cancelButton = nil;
}

@end