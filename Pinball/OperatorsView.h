#import <UIKit/UIKit.h>
#import "Operator.h"

typedef NS_ENUM(NSUInteger, SelectionOperator) {
    SelectionOperatorAll = 0, // All operators
    SelectionOperatorRegion   // Only Operators that have locations attached
};

@protocol OperatorSelectDelegate;

@interface OperatorsView : UITableViewController

@property (nonatomic) id <OperatorSelectDelegate> delegate;
@property (nonatomic) SelectionOperator operator;

@end

@protocol OperatorSelectDelegate <NSObject>

- (void)selectedOperator:(Operator *)operator;

@end
