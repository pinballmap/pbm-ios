//
//  XMLParser.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XMLTable.h"
#import "LocationProfileViewController.h"


@implementation XMLTable
@synthesize loadingPage;
@synthesize tableView2;
@synthesize isParsing;
//@synthesize xmlParser;

-(void) viewDidLoad
{
	isParsing = NO;
	[super viewDidLoad];
}

- (void)viewDidUnload {
	self.loadingPage = nil;
	self.tableView2 = nil;
}

- (void)dealloc {
	//[xmlParser release];
	[loadingPage release];
	[tableView2 release];
    [super dealloc];
}
# pragma mark XML Parsing
- (void)parseXMLFileAtURL:(NSString *)URL
{
	[self showLoaderIcon];
	isParsing = YES;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//you must then convert the path to a proper NSURL or it won't work
	NSURL *xmlURL = [NSURL URLWithString:URL];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	// here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
	// this may be necessary only for the toolchain
	
	NSXMLParser *xmlParser = [[[NSXMLParser alloc] initWithContentsOfURL:xmlURL] autorelease];
	/*
	if(xmlParser != nil)
	{
		xmlParser = nil;
		[xmlParser release];
	}
	xmlParser = [[[NSXMLParser alloc] initWithContentsOfURL:xmlURL] autorelease];*/
	
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[xmlParser setDelegate:self];
	
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	
	[xmlParser parse];
	[pool release];
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{

}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[self hideLoaderIcon];
	//NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	//NSLog(@"error parsing XML: %@", errorString);
	NSString *errorString = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code], [[parser parserError] localizedDescription], [parser lineNumber],	[parser columnNumber]];
	
	//NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
	isParsing = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self hideLoaderIcon];
	isParsing = NO;
	//[xmlParser release];
}
@end

