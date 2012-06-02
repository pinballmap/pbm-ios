#import "PPMDoubleTableCell.h"

@implementation PPMDoubleTableCell
@synthesize subLabel;

- (void)dealloc {
	[subLabel release];
    [super dealloc];
}

@end