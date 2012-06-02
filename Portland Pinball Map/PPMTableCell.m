#import "PPMTableCell.h"

@implementation PPMTableCell
@synthesize nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)dealloc {
	[nameLabel release];
    [super dealloc];
}

@end