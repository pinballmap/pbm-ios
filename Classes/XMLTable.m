#import "XMLTable.h"

@implementation XMLTable
@synthesize loadingPage, tableView2, isParsing;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isPad) {
        return [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || 
        [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight;
    } else {
        return [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown;
    }    
}

- (void)viewDidLoad {
	isParsing = NO;

	[super viewDidLoad];
}

- (void)parseXMLFileAtURL:(NSString *)url {
    NSLog(@"PARSING %@", url);
	[self showLoaderIcon];
	isParsing = YES;
	
	@autoreleasepool {
		NSURL *xmlURL = [NSURL URLWithString:url];
		
		[[NSURLCache sharedURLCache] setMemoryCapacity:0];
		[[NSURLCache sharedURLCache] setDiskCapacity:0];
		
		NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
		[xmlParser setDelegate:self];
		[xmlParser setShouldProcessNamespaces:NO];
		[xmlParser setShouldReportNamespacePrefixes:NO];
		[xmlParser setShouldResolveExternalEntities:NO];
		
		[xmlParser parse];
	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[self hideLoaderIcon];
    
	NSString *errorString = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code], [[parser parserError] localizedDescription], [parser lineNumber], [parser columnNumber]];
		
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
    
	isParsing = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self hideLoaderIcon];
    
	isParsing = NO;
}

@end