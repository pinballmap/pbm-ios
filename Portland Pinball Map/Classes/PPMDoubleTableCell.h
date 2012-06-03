#import "PPMTableCell.h"

@interface PPMDoubleTableCell : PPMTableCell {
	UILabel *subLabel;
}

@property (nonatomic,strong) IBOutlet UILabel *subLabel;

@end