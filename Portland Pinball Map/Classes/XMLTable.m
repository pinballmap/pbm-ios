#import "XMLTable.h"
#import "LocationProfileViewController.h"

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

- (void)dealloc {
	[loadingPage release];
	[tableView2 release];
    [super dealloc];
}

- (void)parseXMLFileAtURL:(NSString *)URL {
	[self showLoaderIcon];
	isParsing = YES;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *xmlURL = [NSURL URLWithString:URL];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	NSXMLParser *xmlParser = [[[NSXMLParser alloc] initWithContentsOfURL:xmlURL] autorelease];
	[xmlParser setDelegate:self];
	
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	
	[xmlParser parse];
	[pool release];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[self hideLoaderIcon];
	NSString *errorString = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code], [[parser parserError] localizedDescription], [parser lineNumber],	[parser columnNumber]];
		
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
	isParsing = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self hideLoaderIcon];
	isParsing = NO;
}

@end