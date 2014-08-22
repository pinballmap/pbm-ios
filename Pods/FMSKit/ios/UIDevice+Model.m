//
//  UIDevice+Model.m
//  Pods
//
//  Created by Frank Michael on 6/2/14.
//
//

#import "UIDevice+Model.h"

@implementation UIDevice (Model)

+ (ModelType)currentModel{
    if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound){
        return ModelTypeiPad;
    }else{
        return ModelTypeiPhone;
    }
}

@end
