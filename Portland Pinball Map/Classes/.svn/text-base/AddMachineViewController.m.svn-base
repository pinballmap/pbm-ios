//
//  AddMachineViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 4/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "AddMachineViewController.h"
#import "LocationObject.h"
#import "Portland_Pinball_MapAppDelegate.h"


@implementation AddMachineViewController
@synthesize picker;
@synthesize textfield;
@synthesize returnButton;
@synthesize submitButton;
@synthesize location;
@synthesize locationName;
@synthesize locationId;
@synthesize selected_machine_id;
@synthesize loaderIcon;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
       
		
	}
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{	
	self.title = @"Add Machine";
	loaderIcon.hidden = YES;
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	textfield.text = @"";
	
	submitButton.hidden = NO;

	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(machineArray != nil)
	{
		[machineArray release];
		machineArray = nil;
	}
	machineArray = [[NSMutableArray alloc] initWithCapacity:[appDelegate.activeRegion.machines count]];
	
	//Add Items from Dictionary to Array
	for(id key in appDelegate.activeRegion.machines)
	{
		NSDictionary *machine = [appDelegate.activeRegion.machines valueForKey:key];
		[machineArray addObject:machine];
	}
	
	//Sort array
	NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)] autorelease];
	[machineArray sortUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
	
	[super viewWillAppear:animated];
}

-(IBAction)onReturnTap:(id)sender
{
	[textfield resignFirstResponder];
}

-(IBAction)onSumbitTap:(id)sender
{
	[textfield resignFirstResponder];
	NSString *newName = textfield.text;
	
	if(![Utils stringIsBlank:newName])
	{
		UIActionSheet *actionsheet = [[UIActionSheet alloc]
									  initWithTitle:@"Are you sure?" 
									  delegate:self 
									  cancelButtonTitle:@"Cancel" 
									  destructiveButtonTitle:nil 
									  otherButtonTitles:@"Make It Happen",nil];
		[actionsheet showInView:self.view];
		[actionsheet release];
	}
	else
	{
		NSString *errorString = [[NSString alloc] initWithFormat:@"Please enter the name of the machine or select it from the list below."];
		UIAlertView *error = [[UIAlertView alloc]
							  initWithTitle:@"Invalid Name"
							  message:errorString
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[error show];
		[error release];
		[errorString release];
	} 
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
		[self addMachineFromTextfield];
	}
	
}

-(NSString*)stripString:(NSString*)string
{
	NSArray *escapeChars = [NSArray arrayWithObjects:
							@";", @"/", @"?", @":",
							@"@", @"&", @"=", @"+",
							@"$", @",", @"[", @"]",
							@"#", @"!", @"|", @"(", 
							@"-",
							@")", @"*", @"'", @" ", nil];
	
	int len = [escapeChars count];
    NSMutableString *temp  = [string mutableCopy];
	NSMutableString *temp2 = [temp lowercaseString];

	for(int i = 0; i < len; i++)
    {
        [temp2 replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString: @""
								 options: NSLiteralSearch
								   range: NSMakeRange(0, [temp2 length])];
    }
	
    NSString *out = [NSString stringWithString: temp2];
	return out;
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	self.submitButton = nil;
	self.returnButton = nil;
	self.textfield = nil;
	self.picker = nil;
	self.loaderIcon = nil;
}


- (void)dealloc
{
	[loaderIcon release];
	[selected_machine_id release];
	[location release];
	[locationName release];
	[locationId   release];
	[submitButton release];
	[returnButton release];
	[machineArray release];
	[picker release];
	[textfield release];
    [super dealloc];
}

+ (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
	return [result autorelease];
}

-(void)addMachineFromTextfield
{
	UIApplication* app = [UIApplication sharedApplication];
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	app.networkActivityIndicatorVisible = YES;
	
	submitButton.hidden = YES;
	[loaderIcon startAnimating];
	
	//Check for existing machine
	
	NSString *newMachine         = [NSString stringWithString:textfield.text];
	NSString *newMachineStripped = [self stripString:newMachine];
	NSString *finalString;
	
	for (int i = 0; i < [machineArray count]; i++)
	{
		NSString *machineName = [NSString stringWithString:[[machineArray objectAtIndex:i] objectForKey:@"name"]];
		NSString *stripped    = [self stripString:machineName];
		
		NSLog(@"comparing strings: %@ and %@",newMachineStripped,stripped);
		
		if([newMachineStripped isEqualToString:stripped])
		{
			NSLog(@"match!");
			finalString = machineName;
			break;
		}
		else
		{
			NSLog(@"no match!");
		}
	}
	
	if(finalString == nil)
		finalString = [NSString stringWithString:textfield.text];
	else 
		textfield.text = finalString;
	
	NSLog(@"final string: %@",finalString);

	//Send Error Report
	NSString* escapedUrl = [AddMachineViewController urlEncodeValue:finalString];//[textfield.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=add_machine&machine_name=%@",
						appDelegate.rootURL,
						location.id_number,
						escapedUrl];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorInBackground:@selector(addMachineWithURL:) withObject:urlstr];
	[pool release];
}

-(void)addMachineWithURL:(NSString*)urlstr
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	UIApplication* app = [UIApplication sharedApplication];
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSURL *url = [[NSURL alloc] initWithString:urlstr];
	NSError *error;
	NSString *test = [NSString stringWithContentsOfURL:url
											  encoding:NSUTF8StringEncoding
												 error:&error];
	[urlstr release];
	[url release];
	
	NSLog(@"php returned %@",test);
	
	//If Success, throw thank you
	NSString *addsuccess = [[NSString alloc] initWithString:@"add successful"];
	NSRange range = [test rangeOfString:addsuccess];
	
	if(range.length > 0)
	{
		NSString *newName = textfield.text;
		NSString *alertString = [[NSString alloc] initWithFormat:@"%@ has been added to %@.",newName,location.name];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Thank You!"
							  message:alertString
							  delegate:self
							  cancelButtonTitle:@"Sweet!"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[alertString release];
		
		app.networkActivityIndicatorVisible = NO;
		[loaderIcon stopAnimating];
		
		//Quick Parse New ID
		NSString *id1 = [[NSString alloc] initWithString:@"<id>\n"];
		NSRange   range1 = [test rangeOfString:id1];
		NSString *id2 = [[NSString alloc] initWithString:@"\n</id>"];
		NSRange   range2 = [test rangeOfString:id2];
		NSRange   range3;
				  range3.location = range1.location + range1.length;
				  range3.length   = range2.location - range1.location - range1.length;
		selected_machine_id = [test substringWithRange:range3];
		
		
		[id1 release];
		[id2 release];
		
		//Adding this location to the loaded machine list on the machine page
		NSMutableDictionary *machine_dict = (NSMutableDictionary *)[appDelegate.activeRegion.machines objectForKey:selected_machine_id];
		
		if(machine_dict == nil)
		{
			machine_dict = [[NSMutableDictionary alloc] init];
			[machine_dict setValue:selected_machine_id forKey:@"id"];
			[machine_dict setValue:newName forKey:@"name"];
			[machine_dict setValue:@"1" forKey:@"numLocations"];
			[appDelegate.activeRegion.machines setObject:machine_dict forKey:selected_machine_id];
			[machine_dict release];
		}
		
		NSLog(@"machine_dict: %@",machine_dict);
		
		NSMutableArray *locationArray = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:selected_machine_id];
		if(locationArray != nil)
		{
			[locationArray addObject:location];
		}
		
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString* erstr = [NSString stringWithFormat:@"| CODE 0002 | %@ | %@ was added to %@ (%@)",appDelegate.activeRegion.formalName, newName, location.name, location.id_number];
		[Utils sendErrorReport:erstr];
	}
	else 
	{
		NSString *alertString2 = [[NSString alloc] initWithString:@"Machine could not be added at this time, please try again later."];
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
		submitButton.hidden = NO;
		[loaderIcon stopAnimating];
	}
	
	[addsuccess release];
	[pool release];
	
}

#pragma mark
#pragma mark Alert View Delegate 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//Confirm 
	if(buttonIndex == 1)
	{
		[self addMachineFromTextfield];
	}
	else if([alertView.title isEqualToString:@"Thank You!"])
	{
		location.isLoaded = NO;
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"clickedButtonAtIndex: %i",buttonIndex);
}



#pragma mark -
#pragma mark Picker Data Source Methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	textfield.text = [[machineArray objectAtIndex:row] objectForKey:@"name"];
	//selected_machine_id = [[machineArray objectAtIndex:row] objectForKey:@"id"];
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component 
{
	return [machineArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [[machineArray objectAtIndex:row] objectForKey:@"name"];
}


@end
