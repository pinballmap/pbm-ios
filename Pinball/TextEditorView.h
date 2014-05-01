//
//  TextEditorView.h
//  Pinball
//
//  Created by Frank Michael on 5/1/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextEditorDelegate;

@interface TextEditorView : UIViewController

@property (nonatomic) id <TextEditorDelegate> delegate;
@property (nonatomic)NSString *textContent;
@property (nonatomic)NSString *editorTitle;

@end


@protocol TextEditorDelegate <NSObject>

- (void)editorDidComplete:(NSString *)text;
- (void)editorDidCancel;

@end