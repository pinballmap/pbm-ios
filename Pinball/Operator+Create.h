#import "Operator.h"

@interface Operator (Create)

+ (instancetype)createOperatorWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context;

@end
