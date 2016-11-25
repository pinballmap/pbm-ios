#import <UIKit/UIKit.h>
#import "Operator.h"

@protocol OperatorSelectDelegate;

@interface OperatorsView : UITableViewController

@property (nonatomic) id <OperatorSelectDelegate> delegate;

@end

@protocol OperatorSelectDelegate <NSObject>

- (void)selectedOperator:(Operator *)operator;

@end
