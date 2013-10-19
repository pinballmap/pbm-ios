//
//  SplashViewController.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/10/13.
//
//

#import <UIKit/UIKit.h>
#import "APIManager.h"

@interface SplashViewController : UIViewController <APIManagerDelegate>
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@end
