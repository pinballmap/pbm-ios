//
//  ReuseWebView.h
//  FMSKit
//
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReuseWebView : UIViewController

- (id)initWithURL:(NSURL *)url;

@property (nonatomic)NSURL *webURL;
@property (nonatomic)NSString *webTitle;
// Default is true.
@property (nonatomic)BOOL scalePages;

@end
