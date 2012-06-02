#import "PPMTableCell.h"

@interface PPMDoubleTableCell : PPMTableCell {
	UILabel *subLabel;
}

@property (nonatomic,retain) IBOutlet UILabel *subLabel;

@end