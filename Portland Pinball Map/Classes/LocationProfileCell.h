@interface LocationProfileCell : UITableViewCell {
	UILabel *label;
	UILabel *addressLabel1;
	UILabel *addressLabel2;
	UILabel *phoneLabel;
	UILabel *distanceLabel;
}

@property (nonatomic,strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic,strong) IBOutlet UILabel *label;
@property (nonatomic,strong) IBOutlet UILabel *addressLabel1;
@property (nonatomic,strong) IBOutlet UILabel *addressLabel2;
@property (nonatomic,strong) IBOutlet UILabel *phoneLabel;

@end