#import "XMLTable.h"
#import "Location.h"

@interface LocationProfileViewController : XMLTable {	  
	UIScrollView *scrollView;

    NSMutableString *mapURL;
	
	Location *activeLocation;
	
	UILabel *mapLabel;
	UIButton *mapButton;
	BOOL showMapButton;
			
	UIButton *addMachineButton;
}

@property (nonatomic,strong) IBOutlet UIButton *addMachineButton;
@property (nonatomic,assign) BOOL showMapButton;
@property (nonatomic,strong) IBOutlet UILabel *mapLabel;
@property (nonatomic,strong) IBOutlet UIButton *mapButton;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) Location *activeLocation;

- (IBAction)mapButtonPressed:(id)sender;
- (IBAction)addMachineButtonPressed:(id)sender;
- (void)refreshAndReload;
- (void)loadLocationData;

@end