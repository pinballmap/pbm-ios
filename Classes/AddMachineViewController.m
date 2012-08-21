#import "Utils.h"
#import "Machine.h"
#import "LocationMachineXref.h"
#import "AddMachineViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation AddMachineViewController
@synthesize picker, textfield, returnButton, submitButton, location, selectedMachineID, loaderIcon, newMachine;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    newMachine = NO;
    
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

- (IBAction)onSubmitTap:(id)sender {
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
        newMachine = YES;
		name = textfield.text;
	}
    
	NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=add_machine&machine_name=%@", appDelegate.rootURL, location.idNumber, [Utils urlEncode:name]];
	
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
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Thank You!"
								  message:[[NSString alloc] initWithFormat:@"%@ has been added to %@.", textfield.text, location.name]
								  delegate:self
								  cancelButtonTitle:@"Sweet!"
								  otherButtonTitles:nil];
			[alert show];
			
			[loaderIcon stopAnimating];
			
            for (int i = 0; i < [response length]; i++) {
                if (isdigit([response characterAtIndex:i])) {
                    NSLog(@"%c",[response characterAtIndex:i]);
                }
            }
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<id>\\s?(\\d+)\\s?<\\/id>" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
            NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
            
            NSRange matchRange = [textCheckingResult rangeAtIndex:1];
            NSString *idNumber = [response substringWithRange:matchRange];
                                    
            Machine *machine;
            if (newMachine) {
                machine = [NSEntityDescription insertNewObjectForEntityForName:@"Machine" inManagedObjectContext:appDelegate.managedObjectContext];
                [machine setValue:textfield.text forKey:@"name"];
                [machine setValue:[NSNumber numberWithInt:[idNumber intValue]] forKey:@"idNumber"];
            } else {
                machine = (Machine *)[appDelegate fetchObject:@"Machine" where:@"idNumber" equals:idNumber];
            }
                
            [appDelegate.activeRegion addMachinesObject:machine];

            LocationMachineXref *lmx = [NSEntityDescription insertNewObjectForEntityForName:@"LocationMachineXref" inManagedObjectContext:appDelegate.managedObjectContext];
            [lmx setLocation:location];
            [lmx setMachine:machine];
            
            [appDelegate saveContext];
        } else {
			UIAlertView *alert = [[UIAlertView alloc]
								   initWithTitle:@"Sorry"
								   message:@"Machine could not be added at this time, please try again later."
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
			[alert show];
			
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
	[textfield setText:[[appDelegate.activeRegion.machines.allObjects objectAtIndex:row] name]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [appDelegate.activeRegion.machines count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [(Machine *)[appDelegate.activeRegion.machines.allObjects objectAtIndex:row] name];
}

@end