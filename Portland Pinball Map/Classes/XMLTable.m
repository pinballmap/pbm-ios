#import "XMLTable.h"

@implementation XMLTable
@synthesize loadingPage, tableView2, isParsing;

- (void)viewDidLoad {
	isParsing = NO;
	[super viewDidLoad];
}

- (void)viewDidUnload {
	self.loadingPage = nil;
	self.tableView2 = nil;
}

- (void)parseXMLFileAtURL:(NSString *)URL {
	[self showLoaderIcon];
	isParsing = YES;
	
	@autoreleasepool {
		NSURL *xmlURL = [NSURL URLWithString:URL];
		
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
		
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
    
	isParsing = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self hideLoaderIcon];
    
	isParsing = NO;
}

@end