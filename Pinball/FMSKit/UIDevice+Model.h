//
//  UIDevice+Model.h
//  Pods
//
//  Created by Frank Michael on 6/2/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ModelType){
    ModelTypeiPhone = 0,
    ModelTypeiPad
};
@interface UIDevice (Model)

+ (ModelType)currentModel;

@end
