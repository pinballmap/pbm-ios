#import "CommentController.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "MachineProfileViewController.h"

@implementation CommentController
@synthesize submitButton, cancelButton, textview, machine, location;

- (void)viewWillAppear:(BOOL)animated {
	self.title = machine.name;
	textview.text = machine.condition;
	[textview becomeFirstResponder];
	[super viewWillAppear:animated];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if(savedConditionText != nil) {
		savedConditionText = nil;
		[savedConditionText release];
	}
	
	savedConditionText = [[NSString alloc] initWithString:textview.text];
}

- (IBAction)onSubmitTap:(id)sender {
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	NSString *newComment = ([textview.text isEqual:@""]) ? @" " : textview.text;
	
	NSString *encodedCondition = [MachineProfileViewController urlEncodeValue:newComment];
	
	NSString *urlstr = [[NSString alloc] initWithFormat:@"%@location_no=%@&machine_no=%@&condition=%@",
						appDelegate.rootURL,
						location.id_number,
						machine.id_number,
						encodedCondition];
	NSURL *url = [[NSURL alloc] initWithString:urlstr];
	NSError *error;
	NSString *test = [NSString stringWithContentsOfURL:url
											  encoding:NSUTF8StringEncoding
												 error:&error];
		
	[urlstr release];
	[url release];
	
	NSString *addsuccess = [[NSString alloc] initWithString:@"success"];
	NSRange range = [test rangeOfString:addsuccess];
	
	if(range.length > 0) {
		NSDate *today = [NSDate date];
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd"];
		
		machine.condition_date = [[[NSString alloc] initWithString:[inputFormatter stringFromDate:today]] autorelease];
		machine.condition      = [[[NSString alloc] initWithString:textview.text] autorelease];
		
		[inputFormatter release];
		
		app.networkActivityIndicatorVisible = NO;
		
		[self.navigationController popViewControllerAnimated:YES];
	} else  {
		NSString *alertString2 = [[NSString alloc] initWithString:@"Machine condition could not be updated at this time, please try again later."];
		UIAlertView *alert2 = [[UIAlertView alloc]
							   initWithTitle:@"Sorry"
							   message:alertString2
							   delegate:nil
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
		[alert2 show];
		[alert2 release];
		[alertString2 release];
		
		app.networkActivityIndicatorVisible = NO;
	}
	
	[addsuccess release];
	
	if(savedConditionText != nil) {
		savedConditionText = nil;
		[savedConditionText release];
	}	
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

- (void)dealloc {
	[location release];
	[machine release];
	[submitButton release];
	[cancelButton release];
	[textview release];
    [super dealloc];
}

@end