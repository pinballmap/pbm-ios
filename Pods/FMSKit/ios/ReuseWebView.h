//
//  ReuseWebView.h
//  ReuseWebView
//
//  Created by Frank Michael on 4/25/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReuseWebView : UIViewController

- (id)initWithURL:(NSURL *)url;

@property (nonatomic)NSURL *webURL;
@property (nonatomic)NSString *webTitle;

@end
