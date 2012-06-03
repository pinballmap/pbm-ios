#import "Utils.h"
#import "AddMachineViewController.h"
#import "LocationObject.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation AddMachineViewController
@synthesize picker, textfield, returnButton, submitButton, location, locationName, locationId, selected_machine_id, loaderIcon;

- (void)viewDidLoad {	
	self.title = @"Add Machine";
	loaderIcon.hidden = YES;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	textfield.text = @"";
	
	submitButton.hidden = NO;

	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(machineArray != nil) {
		machineArray = nil;
	}
	machineArray = [[NSMutableArray alloc] initWithCapacity:[appDelegate.activeRegion.machines count]];
	
	for(id key in appDelegate.activeRegion.machines) {
		NSDictionary *machine = [appDelegate.activeRegion.machines valueForKey:key];
		[machineArray addObject:machine];
	}
	
	NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)];
	[machineArray sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	
	[super viewWillAppear:animated];
}

- (IBAction)onReturnTap:(id)sender {
	[textfield resignFirstResponder];
}

- (IBAction)onSumbitTap:(id)sender {
	[textfield resignFirstResponder];
	NSString *newName = textfield.text;
	
	if(![Utils stringIsBlank:newName]) {
		UIActionSheet *actionsheet = [[UIActionSheet alloc]
									  initWithTitle:@"Are you sure?" 
									  delegate:self 
									  cancelButtonTitle:@"Cancel" 
									  destructiveButtonTitle:nil 
									  otherButtonTitles:@"Make It Happen",nil];
		[actionsheet showInView:self.view];
	} else {
		NSString *errorString = [[NSString alloc] initWithFormat:@"Please enter the name of the machine or select it from the list below."];
		UIAlertView *error = [[UIAlertView alloc]
							  initWithTitle:@"Invalid Name"
							  message:errorString
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[error show];
	} 
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0) {
		[self addMachineFromTextfield];
	}
}

- (NSString *)stripString:(NSString *)string {
	NSArray *escapeChars = [NSArray arrayWithObjects:
							@";", @"/", @"?", @":",
							@"@", @"&", @"=", @"+",
							@"$", @",", @"[", @"]",
							@"#", @"!", @"|", @"(", 
							@"-",
							@")", @"*", @"'", @" ", nil];
	
	int len = [escapeChars count];
    NSMutableString *temp  = [string mutableCopy];
	NSMutableString *temp2 = [[temp lowercaseString] mutableCopy];

	for(int i = 0; i < len; i++) {
        [temp2 replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString: @""
								 options: NSLiteralSearch
								   range: NSMakeRange(0, [temp2 length])];
    }
	
    return temp2;
}

- (void)viewDidUnload {
	self.submitButton = nil;
	self.returnButton = nil;
	self.textfield = nil;
	self.picker = nil;
	self.loaderIcon = nil;
}

-(void)addMachineFromTextfield {
	UIApplication* app = [UIApplication sharedApplication];
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	app.networkActivityIndicatorVisible = YES;
	
	submitButton.hidden = YES;
	[loaderIcon startAnimating];
		
	NSString *newMachine = [NSString stringWithString:textfield.text];
	NSString *newMachineStripped = [self stripString:newMachine];
	NSString *finalString;
	
	for (int i = 0; i < [machineArray count]; i++) {
		NSString *machineName = [NSString stringWithString:[[machineArray objectAtIndex:i] objectForKey:@"name"]];
		NSString *stripped    = [self stripString:machineName];
				
		if([newMachineStripped isEqualToString:stripped]) {
			finalString = machineName;
			break;
		}
	}
	
	if(finalString == nil) {
		finalString = [NSString stringWithString:textfield.text];
	} else { 
		textfield.text = finalString;
	}
     
	NSString* escapedUrl = [Utils urlEncode:finalString];
	NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=add_machine&machine_name=%@",
						appDelegate.rootURL,
						location.id_number,
						escapedUrl];
	
	@autoreleasepool {
		[self performSelectorInBackground:@selector(addMachineWithURL:) withObject:urlstr];
	}
}

-(void)addMachineWithURL:(NSString*)urlstr {
	@autoreleasepool {
	
		UIApplication* app = [UIApplication sharedApplication];
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		NSURL *url = [[NSURL alloc] initWithString:urlstr];
		NSError *error;
		NSString *test = [NSString stringWithContentsOfURL:url
												  encoding:NSUTF8StringEncoding
													 error:&error];

		NSString *addsuccess = [[NSString alloc] initWithString:@"add successful"];
		NSRange range = [test rangeOfString:addsuccess];
		
		if(range.length > 0) {
			NSString *newName = textfield.text;
			NSString *alertString = [[NSString alloc] initWithFormat:@"%@ has been added to %@.",newName,location.name];
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Thank You!"
								  message:alertString
								  delegate:self
								  cancelButtonTitle:@"Sweet!"
								  otherButtonTitles:nil];
			[alert show];
			
			app.networkActivityIndicatorVisible = NO;
			[loaderIcon stopAnimating];
			
			NSString *id1 = [[NSString alloc] initWithString:@"<id>\n"];
			NSRange   range1 = [test rangeOfString:id1];
			NSString *id2 = [[NSString alloc] initWithString:@"\n</id>"];
			NSRange   range2 = [test rangeOfString:id2];
			NSRange   range3;
					  range3.location = range1.location + range1.length;
					  range3.length   = range2.location - range1.location - range1.length;
			selected_machine_id = [test substringWithRange:range3];
			
			
			
			NSMutableDictionary *machine_dict = (NSMutableDictionary *)[appDelegate.activeRegion.machines objectForKey:selected_machine_id];
			
			if(machine_dict == nil) {
				machine_dict = [[NSMutableDictionary alloc] init];
            [machine_dict setValue:selected_machine_id forKey:@"id"];
				[machine_dict setValue:newName forKey:@"name"];
				[machine_dict setValue:@"1" forKey:@"numLocations"];
				[appDelegate.activeRegion.machines setObject:machine_dict forKey:selected_machine_id];
			}
					
			NSMutableArray *locationArray = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:selected_machine_id];
			if(locationArray != nil) {
				[locationArray addObject:location];
			}
        } else {
			NSString *alertString2 = [[NSString alloc] initWithString:@"Machine could not be added at this time, please try again later."];
			UIAlertView *alert2 = [[UIAlertView alloc]
								   initWithTitle:@"Sorry"
								   message:alertString2
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
			[alert2 show];
			
			app.networkActivityIndicatorVisible = NO;
			submitButton.hidden = NO;
			[loaderIcon stopAnimating];
		}
		
	}
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
		[self addMachineFromTextfield];
	} else if([alertView.title isEqualToString:@"Thank You!"]) {
		location.isLoaded = NO;
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"clickedButtonAtIndex: %i",buttonIndex);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	textfield.text = [[machineArray objectAtIndex:row] objectForKey:@"name"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [machineArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[machineArray objectAtIndex:row] objectForKey:@"name"];
}

@end