//
//  TextEditorView.m
//  Pods
//
//  Created by Frank Michael on 6/3/14.
//
//

#import "TextEditorView.h"

@interface TextEditorView () <UITextViewDelegate> {
    UITextView *textView;
}
- (IBAction)saveEditor:(id)sender;
- (IBAction)cancelEditor:(id)sender;

@end

@implementation TextEditorView

- (instancetype)initWithTitle:(NSString *)title andDelegate:(id<TextEditorDelegate>)delegate{
    self = [super init];
    if (self){
        _editorTitle = title;
        _delegate = delegate;
    }
    return self;
}

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
    if (!textView){
        self.view.backgroundColor = [UIColor whiteColor];
        // TextView Setup
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        textView.delegate = self;
        UIEdgeInsets contentInsets;
        if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
            contentInsets = UIEdgeInsetsMake(0, 0, 44, 0);
        }else{
            contentInsets = UIEdgeInsetsMake(20, 0, 44, 0);
        }
        textView.contentInset = contentInsets;
        [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:textView];
        NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[textview]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"textview": textView}];
        NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[textview]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"textview": textView}];
        [self.view addConstraints:horizontal];
        [self.view addConstraints:vertical];
    }
    if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location == NSNotFound){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismissed:) name:UIKeyboardDidHideNotification object:nil];
    }
    UIBarButtonItem *saveAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveEditor:)];
    UIBarButtonItem *cancelAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditor:)];
    self.navigationItem.leftBarButtonItem = cancelAction;
    self.navigationItem.rightBarButtonItem = saveAction;
    self.navigationItem.title = _editorTitle;
    textView.text = _textContent;
}
- (void)setEditorTitle:(NSString *)editorTitle{
    _editorTitle = editorTitle;
}
- (void)setTextContent:(NSString *)textContent{
    _textContent = textContent;
}
- (void)setEditorPrompt:(NSString *)editorPrompt{
    _editorPrompt = editorPrompt;
    self.navigationItem.prompt = _editorPrompt;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
#pragma mark - Keyboard Notifications
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

@end
