#import "Utils.h"
#import "AddMachineViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"

@implementation AddMachineViewController
@synthesize picker, textfield, returnButton, submitButton, location, locationName, locationId, selectedMachineID, loaderIcon;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidLoad {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	[self setTitle:@"Add Machine"];
	[loaderIcon setHidden:YES];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[textfield setText:@""];
	
	[submitButton setHidden:NO];
    
    machines = [[NSMutableArray alloc] initWithCapacity:[appDelegate.activeRegion.machines count]];
	
	for(id key in appDelegate.activeRegion.machines) {
		NSDictionary *machine = [appDelegate.activeRegion.machines valueForKey:key];
		[machines addObject:machine];
	}
	
	NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)];
	[machines sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	
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

- (void)viewDidUnload {
	self.submitButton = nil;
	self.returnButton = nil;
	self.textfield = nil;
	self.picker = nil;
	self.loaderIcon = nil;
}

-(void)addMachineFromTextfield {
	UIApplication* app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];
	
	[submitButton setHidden:YES];
	[loaderIcon startAnimating];
		
	NSString *newMachineStripped = [Utils stripString:[NSString stringWithString:textfield.text]];
	NSString *finalString;
	
	for (int i = 0; i < [machines count]; i++) {
		NSString *machineName = [NSString stringWithString:[[machines objectAtIndex:i] objectForKey:@"name"]];
		NSString *stripped = [Utils stripString:machineName];
				
		if([newMachineStripped isEqualToString:stripped]) {
			finalString = machineName;
			break;
		}
	}
	
	if(finalString == nil) {
		finalString = textfield.text;
	} else { 
		[textfield setText:finalString];
	}
     
	NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=add_machine&machine_name=%@",
						appDelegate.rootURL,
						location.id_number,
						[Utils urlEncode:finalString]];
	
	@autoreleasepool {
		[self performSelectorInBackground:@selector(addMachineWithURL:) withObject:urlstr];
	}
}

-(void)addMachineWithURL:(NSString*)urlstr {
	@autoreleasepool {
		UIApplication *app = [UIApplication sharedApplication];
		
		NSError *error;
		NSString *test = [NSString stringWithContentsOfURL:[[NSURL alloc] initWithString:urlstr]
												  encoding:NSUTF8StringEncoding
													 error:&error];
		NSRange range = [test rangeOfString:@"add successful"];
		
		if(range.length > 0) {
			NSString *newName = textfield.text;
			NSString *alertString = [[NSString alloc] initWithFormat:@"%@ has been added to %@.", newName, location.name];
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Thank You!"
								  message:alertString
								  delegate:self
								  cancelButtonTitle:@"Sweet!"
								  otherButtonTitles:nil];
			[alert show];
			
			[loaderIcon stopAnimating];
			
			NSString *id1 = [[NSString alloc] initWithString:@"<id>\n"];
			NSRange range1 = [test rangeOfString:id1];
			NSString *id2 = [[NSString alloc] initWithString:@"\n</id>"];
			NSRange range2 = [test rangeOfString:id2];
			NSRange range3;
            range3.location = range1.location + range1.length;
            range3.length = range2.location - range1.location - range1.length;
			selectedMachineID = [test substringWithRange:range3];
			
			NSMutableDictionary *machine_dict = (NSMutableDictionary *)[appDelegate.activeRegion.machines objectForKey:selectedMachineID];
			
			if(machine_dict == nil) {
				machine_dict = [[NSMutableDictionary alloc] init];
                [machine_dict setValue:selectedMachineID forKey:@"id"];
				[machine_dict setValue:newName forKey:@"name"];
				[machine_dict setValue:@"1" forKey:@"numLocations"];
				[appDelegate.activeRegion.machines setObject:machine_dict forKey:selectedMachineID];
			}
					
			NSMutableArray *locationArray = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:selectedMachineID];
			if(locationArray != nil) {
				[locationArray addObject:location];
			}
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
	if(buttonIndex == 1) {
		[self addMachineFromTextfield];
	} else if([alertView.title isEqualToString:@"Thank You!"]) {
		[location setIsLoaded:NO];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[textfield setText:[[machines objectAtIndex:row] objectForKey:@"name"]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [machines count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[machines objectAtIndex:row] objectForKey:@"name"];
}

@end