#import "Utils.h"
#import "Machine.h"
#import "AddMachineViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation AddMachineViewController
@synthesize picker, textfield, returnButton, submitButton, location, selectedMachineID, loaderIcon;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	[loaderIcon setHidden:YES];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"Add Machine"];
    [textfield setText:@""];
    
    [submitButton setHidden:NO];
    	
	[super viewWillAppear:animated];
}

- (IBAction)onReturnTap:(id)sender {
	[textfield resignFirstResponder];
}

- (IBAction)onSumbitTap:(id)sender {
	[textfield resignFirstResponder];
	
	if(![Utils stringIsBlank:textfield.text]) {
		UIActionSheet *actionsheet = [[UIActionSheet alloc]
									  initWithTitle:@"Are you sure?" 
									  delegate:self 
									  cancelButtonTitle:@"Cancel" 
									  destructiveButtonTitle:nil 
									  otherButtonTitles:@"Make It Happen",nil];
		[actionsheet showInView:self.view];
	} else {
		UIAlertView *error = [[UIAlertView alloc]
							  initWithTitle:@"Invalid Name"
							  message:@"Please enter the name of the machine or select it from the list below."
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[error show];
	} 
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0)
		[self addMachineFromTextfield];
}

- (void)addMachineFromTextfield {
	UIApplication *app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];
	
	[submitButton setHidden:YES];
	[loaderIcon startAnimating];
		
	NSString *name;
	for (Machine *machine in appDelegate.activeRegion.machines) {				
		if ([[Utils stripString:textfield.text] isEqualToString:[Utils stripString:machine.name]]) {
			name = machine.name;
		}
	}
	
	if (name == nil) {
		name = textfield.text;
	}
    
	NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=add_machine&machine_name=%@",
						appDelegate.rootURL,
						location.idNumber,
						[Utils urlEncode:name]];
	
	@autoreleasepool {
		[self performSelectorInBackground:@selector(addMachineWithURL:) withObject:urlstr];
	}
}

- (void)addMachineWithURL:(NSString*)urlstr {
	@autoreleasepool {
		UIApplication *app = [UIApplication sharedApplication];
		
		NSError *error;
		NSString *response = [NSString stringWithContentsOfURL:[[NSURL alloc] initWithString:urlstr]
												  encoding:NSUTF8StringEncoding
													 error:&error];
		NSRange range = [response rangeOfString:@"add successful"];
		if(range.length > 0) {
			NSString *alertString = [[NSString alloc] initWithFormat:@"%@ has been added to %@.", textfield.text, location.name];
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Thank You!"
								  message:alertString
								  delegate:self
								  cancelButtonTitle:@"Sweet!"
								  otherButtonTitles:nil];
			[alert show];
			
			[loaderIcon stopAnimating];
			
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<id>\n(.*)\n</id>" options:NSRegularExpressionCaseInsensitive error:nil];
            NSRange range = [regex rangeOfFirstMatchInString:response options:0 range:NSMakeRange(0, [response length])];
            NSNumber *idNumber = [NSNumber numberWithInt:[[response substringWithRange:range] intValue]];
                        
            NSManagedObject *machine = [NSEntityDescription insertNewObjectForEntityForName:@"Machine" inManagedObjectContext:appDelegate.managedObjectContext];
            [machine setValue:textfield.text forKey:@"name"];
            [machine setValue:idNumber forKey:@"locationID"];
			[appDelegate saveContext];
        } else {
			UIAlertView *alert2 = [[UIAlertView alloc]
								   initWithTitle:@"Sorry"
								   message:@"Machine could not be added at this time, please try again later."
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
			[alert2 show];
			
			[submitButton setHidden:NO];
			[loaderIcon stopAnimating];
		}
        
        [app setNetworkActivityIndicatorVisible:NO];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self addMachineFromTextfield];
	} else if([alertView.title isEqualToString:@"Thank You!"]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[textfield setText:[[appDelegate.activeRegion.machines.allObjects objectAtIndex:row] objectForKey:@"name"]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [appDelegate.activeRegion.machines count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[appDelegate.activeRegion.machines.allObjects objectAtIndex:row] objectForKey:@"name"];
}

@end