#import "LocationProfileCell.h"

@implementation LocationProfileCell
@synthesize phoneLabel, addressLabel1, addressLabel2, label, distanceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {}
    return self;
}

- (void)setHighlighted:(BOOL)animated {}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

@end