#import "Operator+Create.h"

@implementation Operator (Create)

+ (instancetype)createOperatorWithData:(NSDictionary *)data andContext:(NSManagedObjectContext *)context{
    if (!context){
        context = [[CoreDataManager sharedInstance] managedObjectContext];
    }
    
    Operator *newOperator = [NSEntityDescription insertNewObjectForEntityForName:@"Operator" inManagedObjectContext:context];
    newOperator.operatorId = data[@"id"];
    newOperator.name = data[@"name"];
    newOperator.regionId = data[@"region_id"];
    
    return newOperator;
}

@end
