#import "Utils.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "MachineProfileViewController.h"

@implementation MachineProfileViewController
@synthesize machineLabel, deleteButton, locationMachineXref, locationLabel, conditionLabel, conditionField, returnButton, ipdbButton, otherLocationsButton, updateConditionButton, commentController, webview, machineFilter;

Portland_Pinball_MapAppDelegate *appDelegate;

- (void)viewDidAppear:(BOOL)animated {
    appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];

	[self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:locationMachineXref.location.name];
	
	[self hideControllButtons:YES];
		
	[machineLabel setText:locationMachineXref.machine.name];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateAdded = [formatter stringFromDate:locationMachineXref.dateAdded];
    
    [locationLabel setText:[NSString stringWithFormat:@"%@", [Utils stringIsBlank:dateAdded] ?
        @"" :
        [NSString stringWithFormat:@"added %@", [Utils formatDateFromString:dateAdded]]
    ]];
	
	if ([Utils stringIsBlank:locationMachineXref.condition]) {
		[conditionField setFont:[UIFont italicSystemFontOfSize:14]];
		[conditionField setText:@"Tap below to comment on this machine's condition."];
	} else {
		[conditionField setFont:[UIFont systemFontOfSize:14]];
		[conditionField setText:locationMachineXref.condition];
	}
	
    NSString *conditionDate = [formatter stringFromDate:locationMachineXref.conditionDate];
    [conditionLabel setText:[NSString stringWithFormat:@"%@", (conditionDate != nil) ?
        [NSString stringWithFormat:@"Last Updated - %@", [Utils formatDateFromString:conditionDate]] :
        @""
    ]];
	
	[super viewWillAppear:animated];
}

- (IBAction) onEditButtonPressed:(id)sender {
	[self hideControllButtons:!deleteButton.hidden];
}

- (void)hideControllButtons:(BOOL)doHide {
	[deleteButton setHidden:doHide];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:doHide ? @"Edit" : @"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(onEditButtonPressed:)]];    
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
		UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:YES];
			
		NSString *urlstr = [[NSString alloc] initWithFormat:@"%@modify_location=%@&action=remove_machine&machine_no=%@",
								appDelegate.rootURL,
								locationMachineXref.location.idNumber,
								locationMachineXref.machine.idNumber];
		
		@autoreleasepool {
			[self performSelectorInBackground:@selector(removeMachineWithURL:) withObject:urlstr];
		}
	}
			
}

- (void)removeMachineWithURL:(NSString *)urlstr {
	@autoreleasepool {	
		UIApplication *app = [UIApplication sharedApplication];
		
		NSError *error;
		NSString *test = [NSString stringWithContentsOfURL:[[NSURL alloc] initWithString:urlstr]
												  encoding:NSUTF8StringEncoding
													 error:&error];
		
		NSRange range = [test rangeOfString:@"remove successful"];
		
		if(range.length > 0) {
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Thank You!"
								  message:@"Machine removed."
								  delegate:self
								  cancelButtonTitle:@"Good riddance!"
								  otherButtonTitles:nil];
			[alert show];
            
            [appDelegate.managedObjectContext deleteObject:locationMachineXref];
            [appDelegate saveContext];
		} else {
			UIAlertView *alert2 = [[UIAlertView alloc]
								   initWithTitle:@"Sorry"
								   message:@"Machine could not be removed at this time, please try again later."
								   delegate:nil
								   cancelButtonTitle:@"Fine"
								   otherButtonTitles:nil];
			[alert2 show];			
		}
		
        [app setNetworkActivityIndicatorVisible:NO];
	}
}

- (IBAction)onUpdateConditionTap:(id)sender {
	if(commentController == nil) {
		commentController = [[CommentController alloc] initWithNibName:@"CommentView" bundle:nil];
	}
	
	[commentController setLocationMachineXref:locationMachineXref];
	[commentController setTitle:locationMachineXref.machine.name];
	
	[self.navigationController pushViewController:commentController animated:YES];
}

- (IBAction)onReturnTap:(id)sender {
	[conditionField resignFirstResponder];
}

- (IBAction)onIPDBTap:(id)sender {
	if(webview == nil)
		webview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];	
	
	[webview setTitle:@"Internet Pinball Database"];
	[webview setTheNewURL:[NSString stringWithFormat:@"http://ipdb.org/search.pl?name=%@&qh=checked&searchtype=advanced", [Utils urlEncode:locationMachineXref.machine.name]]];
	
	[self.navigationController pushViewController:webview animated:YES];
}

- (IBAction)onOtherLocationsTap:(id)sender {
	if(machineFilter == nil) {
		machineFilter = [[MachineFilterView alloc] initWithStyle:UITableViewStylePlain];
	}
    
	[machineFilter setResetNavigationStackOnLocationSelect:YES];
	[machineFilter setMachine:locationMachineXref.machine];
    
	[self.navigationController pushViewController:machineFilter animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([alertView.title isEqualToString:@"Thank You!"]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

@end