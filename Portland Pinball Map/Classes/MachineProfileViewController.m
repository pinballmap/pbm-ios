#import "Utils.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "LocationProfileViewController.h"

@implementation MachineProfileViewController
@synthesize machineLabel, deleteButton, machine, location, locationLabel, conditionLabel, conditionField, returnButton, ipdbButton, otherLocationsButton, updateConditionButton, commentController, webview, machineFilter;

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {	
	[self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = location.name;
	
	[self hideControllButtons:YES];
		
	machineLabel.text = [NSString stringWithString:machine.name];
	
	if([machine.dateAdded isEqualToString:@""]) {
		locationLabel.text  = @"";
	} else {
		locationLabel.text  = [NSString stringWithFormat:@"added %@",[Utils formatDateFromString:machine.dateAdded]];
	}
	
	if([Utils stringIsBlank:machine.condition]) {
		conditionField.font = [UIFont italicSystemFontOfSize:14];
		conditionField.text = @"Tap below to comment on this machine's condition.";
	} else {
		conditionField.font = [UIFont systemFontOfSize:14];
		conditionField.text = machine.condition;
	}
	
	if(machine.conditionDate != nil) {
		conditionLabel.text = [NSString stringWithFormat:@"Last Updated - %@", [Utils formatDateFromString:machine.conditionDate]];
	} else { 
		conditionLabel.text = @"";
    }
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.title = @"back";
	//[self resignFirstResponder];
	[super viewWillDisappear:animated];
}

- (IBAction) onEditButtonPressed:(id)sender {
	[self hideControllButtons:!deleteButton.hidden];
}

- (void)hideControllButtons:(BOOL)doHide {
	deleteButton.hidden = doHide;
    
	if(doHide) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStyleBordered target:self action:@selector(onEditButtonPressed:)];	
	} else { 
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStyleBordered target:self action:@selector(onEditButtonPressed:)];	
	}
}

- (IBAction)onDeleteTap:(id)sender {
 	UIActionSheet *actionsheet = [[UIActionSheet alloc]
								  initWithTitle:@"Are you sure?" 
								  delegate:self 
								  cancelButtonTitle:@"Cancel" 
								  destructiveButtonTitle:@"Remove" 
								  otherButtonTitles:nil];
	[actionsheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0) {
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		UIApplication *app = [UIApplication sharedApplication];
					   app.networkActivityIndicatorVisible = YES;
			
		NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=remove_machine&machine_no=%@",
								appDelegate.rootURL,
								location.id_number,
								machine.idNumber];
		
		@autoreleasepool {
			[self performSelectorInBackground:@selector(removeMachineWithURL:) withObject:urlstr];
		}
	}
			
}

- (void)removeMachineWithURL:(NSString *)urlstr {
	@autoreleasepool {
	
		Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
		UIApplication *app = [UIApplication sharedApplication];
		
		
		NSURL    *url = [[NSURL alloc] initWithString:urlstr];
		NSError  *error;
		NSString *test = [NSString stringWithContentsOfURL:url
												  encoding:NSUTF8StringEncoding
													 error:&error];
		
		NSString *addsuccess = [[NSString alloc] initWithString:@"remove successful"];
		NSRange range = [test rangeOfString:addsuccess];
		
		if(range.length > 0) {
			NSString *alertString = [[NSString alloc] initWithString:@"Machine removed."];
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Thank You!"
								  message:alertString
								  delegate:self
								  cancelButtonTitle:@"Good riddance!"
								  otherButtonTitles:nil];
			[alert show];
			
			app.networkActivityIndicatorVisible = NO;
			
			NSMutableArray *locationArray = (NSMutableArray *)[appDelegate.activeRegion.loadedMachines objectForKey:machine.idNumber];
			if(locationArray != nil) {
				[locationArray removeObject:location];
			}
		} else {
			NSString *alertString2 = [[NSString alloc] initWithString:@"Machine could not be removed at this time, please try again later."];
			UIAlertView *alert2 = [[UIAlertView alloc]
								   initWithTitle:@"Sorry"
								   message:alertString2
								   delegate:nil
								   cancelButtonTitle:@"Fine"
								   otherButtonTitles:nil];
			[alert2 show];
			
			app.networkActivityIndicatorVisible = NO;
		}
		
	}
}

- (IBAction)onUpdateConditionTap:(id)sender {
	if(commentController == nil) {
		commentController = [[CommentController alloc] initWithNibName:@"CommentView" bundle:nil];
	}
	
	commentController.machine = machine;
	commentController.location = location;
	commentController.title = machine.name;
	
	[self.navigationController pushViewController:commentController animated:YES];
}

- (IBAction)onReturnTap:(id)sender {
	[conditionField resignFirstResponder];
}

- (IBAction)onIPDBTap:(id)sender {
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	webview.title = @"Internet Pinball Database";
	webview.theNewURL = [NSString stringWithFormat:@"http://ipdb.org/search.pl?name=%@&qh=checked&searchtype=advanced",[Utils urlEncode:machine.name]];
	
	[self.navigationController pushViewController:webview animated:YES];
}

- (IBAction)onOtherLocationsTap:(id)sender {
	if(machineFilter == nil) {
		machineFilter = [[MachineFilterView alloc] initWithStyle:UITableViewStylePlain];
	}
    
	machineFilter.resetNavigationStackOnLocationSelect = YES;
	machineFilter.machineName                          = machine.name;
	machineFilter.machineID                            = machine.idNumber;
	[self.navigationController pushViewController:machineFilter  animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if([alertView.title isEqualToString:@"Thank You!"]) {
		location.isLoaded = NO;
		[self.navigationController popViewControllerAnimated:YES];
	}
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

@end