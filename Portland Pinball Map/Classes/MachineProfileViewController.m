//
//  MachineProfileViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 5/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "MachineProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "LocationProfileViewController.h"

@implementation MachineProfileViewController
@synthesize machineLabel;
@synthesize deleteButton;
@synthesize machine;
@synthesize location;
@synthesize locationLabel;
@synthesize conditionLabel;
@synthesize conditionField;
@synthesize returnButton;
@synthesize ipdbButton;
@synthesize otherLocationsButton;
@synthesize updateConditionButton;
@synthesize commentController;
@synthesize webview;
@synthesize machineFilter;

//?modify_location=XXX;action=remove_machine;machine_no=YYY

-(BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	
    //[super viewDidAppear:animated];
	[self becomeFirstResponder];
}

-(void)viewDidLoad
{
	dayRange2.location = 8;
	dayRange2.length = 2;
	
	monthRange2.location = 5;
	monthRange2.length = 2;
	
	yearRange2.location = 0;
	yearRange2.length = 4;
	
	
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	self.title = location.name;
	
	[self hideControllButtons:YES];
	
	//NSLog(@"Machine profile will appear");
	
	machineLabel.text   = [NSString stringWithString:machine.name];
	
	if([machine.dateAdded isEqualToString:@""])
	{
		locationLabel.text  = @"";
	}
	else
	{
		locationLabel.text  = [NSString stringWithFormat:@"added %@",[self formatDateFromString:machine.dateAdded]];
	}
	
	//temp_machine_object.dateAdded      = [self formatDateFromString:temp_machine_dateAdded];
	//temp_machine_object.condition_date = [self formatDateFromString:temp_machine_condition_date];

	
	if([Utils stringIsBlank:machine.condition])
	{
		conditionField.font = [UIFont italicSystemFontOfSize:14];
		conditionField.text = @"Tap below to comment on this machine's condition.";
	}
	else
	{
		conditionField.font = [UIFont systemFontOfSize:14];
		conditionField.text = machine.condition;
	}
	
	if(machine.condition_date != nil)
		conditionLabel.text = [NSString stringWithFormat:@"Last Updated - %@", [self formatDateFromString:machine.condition_date]];
	else 
		conditionLabel.text = @"";

	
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.title = @"back";
	//[self resignFirstResponder];
	[super viewWillDisappear:animated];
}

-(IBAction) onEditButtonPressed:(id)sender
{
	[self hideControllButtons:!deleteButton.hidden];
}

-(void)hideControllButtons:(BOOL)doHide
{
	deleteButton.hidden          = doHide;
	//updateConditionButton.hidden = doHide;
	if(doHide)
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStyleBordered target:self action:@selector(onEditButtonPressed:)] autorelease];	
	else 
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStyleBordered target:self action:@selector(onEditButtonPressed:)] autorelease];	
	

}

#pragma mark Delete Button
-(IBAction)onDeleteTap:(id)sender
{
	
	UIActionSheet *actionsheet = [[UIActionSheet alloc]
								  initWithTitle:@"Are you sure?" 
								  delegate:self 
								  cancelButtonTitle:@"Cancel" 
								  destructiveButtonTitle:@"Remove" 
								  otherButtonTitles:nil];
	[actionsheet showInView:self.view];
	[actionsheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		UIApplication *app = [UIApplication sharedApplication];
					   app.networkActivityIndicatorVisible = YES;
		//machineLabel.hidden = YES;
			
		NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=remove_machine&machine_no=%@",
								appDelegate.rootURL,
								location.id_number,
								machine.id_number];
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[self performSelectorInBackground:@selector(removeMachineWithURL:) withObject:urlstr];
		[pool release];
		//[self removeMachineWithURL:urlstr];
	}
			
}

-(void)removeMachineWithURL:(NSString*)urlstr
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIApplication *app = [UIApplication sharedApplication];
	
	
	NSURL    *url = [[NSURL alloc] initWithString:urlstr];
	NSError  *error;
	NSString *test = [NSString stringWithContentsOfURL:url
											  encoding:NSUTF8StringEncoding
												 error:&error];
	[urlstr release];
	[url release];
	
	//If Success, throw thank you
	NSString *addsuccess = [[NSString alloc] initWithString:@"remove successful"];
	NSRange range = [test rangeOfString:addsuccess];
	
	if(range.length > 0)
	{
		NSString *alertString = [[NSString alloc] initWithString:@"Machine removed."];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Thank You!"
							  message:alertString
							  delegate:self
							  cancelButtonTitle:@"Good riddance!"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[alertString release];
		
		app.networkActivityIndicatorVisible = NO;
		//machineLabel.hidden = NO;
		
		//Remove Location from loaded machines
		NSMutableArray *locationArray = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:machine.id_number];
		if(locationArray != nil)
		{
			[locationArray removeObject:location];
		}
	}
	else 
	{
		NSString *alertString2 = [[NSString alloc] initWithString:@"Machine could not be removed at this time, please try again later."];
		UIAlertView *alert2 = [[UIAlertView alloc]
							   initWithTitle:@"Sorry"
							   message:alertString2
							   delegate:nil
							   cancelButtonTitle:@"Fine"
							   otherButtonTitles:nil];
		[alert2 show];
		[alert2 release];
		[alertString2 release];
		
		app.networkActivityIndicatorVisible = NO;
	}
	
	[addsuccess release];
	[pool release];
}

#pragma mark Buttons!

-(IBAction)onUpdateConditionTap:(id)sender
{
	if(commentController == nil)
	{
		commentController = [[CommentController alloc] initWithNibName:@"CommentView" bundle:nil];
	}
	
	commentController.machine = machine;
	commentController.location = location;
	commentController.title = machine.name;
	
	[self.navigationController pushViewController:commentController animated:YES];
}

-(IBAction)onReturnTap:(id)sender
{
	[conditionField resignFirstResponder];
}

-(IBAction)onIPDBTap:(id)sender
{
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	webview.title = @"Internet Pinball Database";
	webview.newURL = [NSString stringWithFormat:@"http://ipdb.org/search.pl?name=%@&qh=checked&searchtype=advanced",[MachineProfileViewController urlEncodeValue:machine.name]];
	
	[self.navigationController pushViewController:webview animated:YES];
	//http://ipdb.org/search.pl?name=Bad%20Cats&qh=checked&searchtype=advanced
}

-(IBAction)onOtherLocationsTap:(id)sender
{
	if(machineFilter == nil)
	{
		machineFilter = [[MachineFilterView alloc] initWithStyle:UITableViewStylePlain];
		
	}
	machineFilter.resetNavigationStackOnLocationSelect = YES;
	machineFilter.machineName                          = machine.name;
	machineFilter.machineID                            = machine.id_number;
	[self.navigationController pushViewController:machineFilter  animated:YES];
}

#pragma mark
#pragma mark Alert View Delegate 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	if([alertView.title isEqualToString:@"Thank You!"])
	{
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString *erstr = [NSString stringWithFormat:@"| CODE 0003 | %@ | %@ was removed from %@ (%@).",
						  appDelegate.activeRegion.formalName, machine.name,location.name,location.id_number];
		[Utils sendErrorReport:erstr];
		
		location.isLoaded = NO;
		[self.navigationController popViewControllerAnimated:YES];
	}
	else if([alertView.title isEqualToString:@"Remove Machine"])
	{
		
	}
}

+ (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
	return [result autorelease];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.deleteButton = nil;
	self.machineLabel = nil;
	self.ipdbButton = nil;
	self.returnButton = nil;
	self.conditionField = nil;
	self.conditionLabel = nil;
	self.locationLabel = nil;
	self.updateConditionButton = nil;
}


- (void)dealloc
{
	[machineFilter release];
	[webview release];
	[otherLocationsButton release];
	[updateConditionButton release];
	[locationLabel release];
	[ipdbButton release];
	[returnButton release];
	[location release];
	[machine release];
	[deleteButton release];
	[machineLabel release];
    [super dealloc];
}


/*-(NSDate *)getDateFromString:(NSString *)dateString
{
	NSRange dayRange;
	NSRange monthRange;
	NSRange yearRange;
	
	dayRange.location = 9;
	dayRange.length = 2;
	
	monthRange.location = 6;
	monthRange.length = 2;
	
	yearRange.location = 0;
	yearRange.length = 4;
	
	NSString *day   = [[NSString alloc] initWithString:[dateString substringWithRange:dayRange]];
	NSString *year  = [[NSString alloc] initWithString:[dateString substringWithRange:yearRange]];
	NSString *month = [[NSString alloc] initWithString:[dateString substringWithRange:monthRange]];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *returnDate = [inputFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",year,month,day]];
	
	[day release];
	[year release];
	[month release];
	[inputFormatter release];
	
	return returnDate;
}*/

-(NSString*)formatDateFromString:(NSString*)dateString
{	
	
	NSString *year  = [[NSString alloc] initWithString:[dateString substringWithRange:yearRange2]];
	
	//Get Month
	NSString *month = [[NSString alloc] initWithString:[dateString substringWithRange:monthRange2]];
	NSString *displayMonth;
	
	if      ([month isEqualToString:@"01"]) displayMonth = [[NSString alloc] initWithString:@"Jan"];
	else if ([month isEqualToString:@"02"]) displayMonth = [[NSString alloc] initWithString:@"Feb"];
	else if ([month isEqualToString:@"03"]) displayMonth = [[NSString alloc] initWithString:@"March"];
	else if ([month isEqualToString:@"04"]) displayMonth = [[NSString alloc] initWithString:@"April"];
	else if ([month isEqualToString:@"05"]) displayMonth = [[NSString alloc] initWithString:@"May"];
	else if ([month isEqualToString:@"06"]) displayMonth = [[NSString alloc] initWithString:@"June"];
	else if ([month isEqualToString:@"07"]) displayMonth = [[NSString alloc] initWithString:@"July"];
	else if ([month isEqualToString:@"08"]) displayMonth = [[NSString alloc] initWithString:@"Aug"];
	else if ([month isEqualToString:@"09"]) displayMonth = [[NSString alloc] initWithString:@"Sep"];
	else if ([month isEqualToString:@"10"]) displayMonth = [[NSString alloc] initWithString:@"Oct"];
	else if ([month isEqualToString:@"11"]) displayMonth = [[NSString alloc] initWithString:@"Nov"];
	else								    displayMonth = [[NSString alloc] initWithString:@"Dec"];
	
	//Get Day String
	NSRange digit;
	digit.length   = 1;
	digit.location = 1;
	
	NSString *day       = [[NSString alloc] initWithString:[dateString substringWithRange:dayRange2]];
	NSString *lastDigit = [[NSString alloc] initWithString:[day substringWithRange:digit]];
	NSString *extra;
	if      ([day isEqualToString:@"11"])      extra = [[NSString alloc] initWithString:@"th"];
	else if ([day isEqualToString:@"12"])      extra = [[NSString alloc] initWithString:@"th"];
	else if ([day isEqualToString:@"13"])      extra = [[NSString alloc] initWithString:@"th"];
	else if ([lastDigit isEqualToString:@"1"]) extra = [[NSString alloc] initWithString:@"st"];
	else if ([lastDigit isEqualToString:@"2"]) extra = [[NSString alloc] initWithString:@"nd"];
	else if ([lastDigit isEqualToString:@"3"]) extra = [[NSString alloc] initWithString:@"rd"];
	else                                       extra = [[NSString alloc] initWithString:@"th"];
	
	NSString *dayString = [NSString stringWithFormat:@"%i%@",[day intValue],extra];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *date = [inputFormatter dateFromString:dateString];

	//NSDate *date = [self getDateFromString:dateString];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	//NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
	//int weekday = [weekdayComponents weekday];
	
	//Build String
	NSString *returnString = [[NSString alloc] initWithFormat:@"%@ %@, %@",displayMonth,dayString,year];
	
	//release everything
	[day release];
	[year release];
	[month release];
	[displayMonth release];
	[gregorian release];
	[extra release];
	[lastDigit release];	
	return returnString;
}

@end
