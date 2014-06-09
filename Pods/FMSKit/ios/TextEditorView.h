//
//  TextEditorView.h
//  Pods
//
//  Created by Frank Michael on 6/3/14.
//
//

#import <UIKit/UIKit.h>

@protocol TextEditorDelegate;

@interface TextEditorView : UIViewController

- (instancetype)initWithTitle:(NSString *)title andDelegate:(id<TextEditorDelegate>)delegate;

@property (nonatomic,assign) id <TextEditorDelegate> delegate;
@property (nonatomic,assign)NSString *textContent;
@property (nonatomic,assign)NSString *editorTitle;

@end


@protocol TextEditorDelegate <NSObject>

- (void)editorDidComplete:(NSString *)text;
- (void)editorDidCancel;

@end