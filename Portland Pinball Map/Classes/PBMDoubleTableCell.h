#import "PBMTableCell.h"

@interface PBMDoubleTableCell : PBMTableCell {
	UILabel *subLabel;
}

@property (nonatomic,strong) IBOutlet UILabel *subLabel;

@end