//
//  XMLParser.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlackTableViewController.h"
//@class LocationProfileViewController;


@interface XMLTable : BlackTableViewController
{
	
	BOOL isParsing;
	NSString * currentElement;
	
	UIView *loadingPage;
	UITableView *tableView2;
	
	UIActivityIndicatorView   *indicator;
	
	//NSXMLParser *xmlParser;

}

//@property (nonatomic,retain) NSXMLParser *xmlParser;
@property (nonatomic,assign) BOOL isParsing;
@property (nonatomic,retain) IBOutlet UIView *loadingPage;
@property (nonatomic,retain) IBOutlet UIView *tableView2;

- (void)parseXMLFileAtURL:(NSString *)URL;

@end
