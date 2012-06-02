@interface LocationProfileCell : UITableViewCell {
	UILabel *label;
	UILabel *addressLabel1;
	UILabel *addressLabel2;
	UILabel *phoneLabel;
	UILabel *distanceLabel;
}

@property (nonatomic,retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic,retain) IBOutlet UILabel *label;
@property (nonatomic,retain) IBOutlet UILabel *addressLabel1;
@property (nonatomic,retain) IBOutlet UILabel *addressLabel2;
@property (nonatomic,retain) IBOutlet UILabel *phoneLabel;

@end