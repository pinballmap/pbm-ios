//
//  TextEditorView.m
//  Pinball
//
//  Created by Frank Michael on 5/1/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "TextEditorView.h"

@interface TextEditorView () <UITextViewDelegate> {
    IBOutlet UITextView *textView;
}
- (IBAction)saveEditor:(id)sender;
- (IBAction)cancelEditor:(id)sender;

@end

@implementation TextEditorView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_textContent){
        textView.text = _textContent;
    }
    if (_editorTitle){
        self.navigationItem.title = _editorTitle;
    }else{
        self.navigationItem.title = @"Editor";
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismissed:) name:UIKeyboardDidHideNotification object:nil];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)keyboardShown:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height-keyboardSize.height)];
}
- (void)keyboardDismissed:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height+keyboardSize.height)];
}

#pragma mark - Class Actions
- (IBAction)saveEditor:(id)sender{
    if ([_delegate respondsToSelector:@selector(editorDidComplete:)]){
        [_delegate editorDidComplete:textView.text];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelEditor:(id)sender{
    if ([_delegate respondsToSelector:@selector(editorDidCancel)]){
        [_delegate editorDidCancel];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
