//
//  RSSViewController.h
//  Portland Pinball Map
//
//  Created By Isaac Ruiz on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLTable.h"
#import "PPMTableCell.h"
#import "LocationProfileViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"


@interface RSSViewController : XMLTable
{
	NSMutableDictionary * item;
	NSMutableString * currentTitle;
	NSMutableString * currentDesc;
	
	//NSString *currentElement;
	
	NSRange dayRange;
	NSRange monthRange;
	NSRange yearRange;
	
	NSMutableArray *sectionArray;
	NSMutableArray *sectionTitles;
	
	NSDate *today;
	
	BOOL parsingItemNode;
	
	LocationProfileViewController *childController;
}

- (int)differenceInDaysFrom:(NSDate *)startDate to:(NSDate *)toDate;
//- (void)parseXMLFileAtURL:(NSString *)URL;

@property (nonatomic,retain) NSDate         *today;
@property (nonatomic,retain) NSMutableArray *sectionArray;
@property (nonatomic,retain) NSMutableArray *sectionTitles;
@end
