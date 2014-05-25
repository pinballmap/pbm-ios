//
//  ReuseWebView.m
//  ReuseWebView
//
//  Created by Frank Michael on 4/25/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "ReuseWebView.h"
#import "SafariActivity.h"

@interface ReuseWebView () <UIWebViewDelegate>{
    UIWebView *mainWebView;
    UIToolbar *actionsBar;
    UIBarButtonItem *webBack;
    UIBarButtonItem *webForward;
    UIBarButtonItem *webStop;
    UIBarButtonItem *webRefresh;
    UIActivityIndicatorView *webviewSpinner;
}
- (IBAction)showActivity:(id)sender;
- (IBAction)dismissWeb:(id)sender;
@end

@implementation ReuseWebView

- (id)init{
    self = [super init];
    if (self){

    }
    return self;
}
- (id)initWithURL:(NSURL *)url{
    self = [super init];;
    if (self){
        _webURL = url;
    }
    return self;
}
- (void)setupClass{
    if (!mainWebView){
        self.view.backgroundColor = [UIColor whiteColor];
        // WebView setup
        mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        mainWebView.backgroundColor = [UIColor whiteColor];
        mainWebView.delegate = self;
        mainWebView.scalesPageToFit = YES;
        UIEdgeInsets contentInsets;
        if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
            contentInsets = UIEdgeInsetsMake(0, 0, 44, 0);
        }else{
            contentInsets = UIEdgeInsetsMake(20, 0, 44, 0);
        }
        mainWebView.scrollView.contentInset = contentInsets;
        [mainWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:mainWebView];
        // Autolayout constraints for WebView
        NSArray *horizontalWebView = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[webview]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"webview": mainWebView}];
        NSArray *verticalWebView = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[webview]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"webview": mainWebView}];
        [self.view addConstraints:horizontalWebView];
        [self.view addConstraints:verticalWebView];
        // Toolbar setup.
        actionsBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
        webBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"765-arrow-left"] style:UIBarButtonItemStylePlain target:mainWebView action:@selector(goBack)];
        webBack.enabled = NO;
        webForward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"766-arrow-right"] style:UIBarButtonItemStylePlain target:mainWebView action:@selector(goForward)];
        webForward.enabled = NO;
        webRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:mainWebView action:@selector(reload)];
        webStop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:mainWebView action:@selector(stopLoading)];
        UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActivity:)];
        UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        actionsBar.items = @[webBack,flexspace,webForward,flexspace,webRefresh,flexspace,webStop,flexspace,action];
        [actionsBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:actionsBar];
        // Autolayout constraints for Toolbar
        NSArray *horizontalToolbar = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[toolbar]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"toolbar": actionsBar}];
        NSArray *verticalToolbar = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbar]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"toolbar": actionsBar}];
        [self.view addConstraints:horizontalToolbar];
        [self.view addConstraints:verticalToolbar];
        // Webview Spinner setup
        webviewSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [webviewSpinner startAnimating];
        [webviewSpinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:webviewSpinner];
        NSArray *horizontalSpinner = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[spinner]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"spinner": webviewSpinner}];
        NSArray *verticalSpinner = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[spinner]-(0)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"spinner": webviewSpinner}];
        [self.view addConstraints:horizontalSpinner];
        [self.view addConstraints:verticalSpinner];
        if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
            // Navigation bar setup
            UIBarButtonItem *dismissView = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissWeb:)];
            self.navigationItem.leftBarButtonItem = dismissView;
        }
    }
}
#pragma mark - Class
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupClass];
    self.navigationItem.title = _webTitle;
    [mainWebView loadRequest:[NSURLRequest requestWithURL:_webURL]];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class Actions
- (IBAction)showActivity:(id)sender{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[_webURL] applicationActivities:@[[SafariActivity new]]];
    [self presentViewController:activityVC animated:YES completion:nil];
}
- (IBAction)dismissWeb:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    webStop.enabled = YES;
    [webviewSpinner startAnimating];
    if (webView.canGoBack){
        webBack.enabled = YES;
    }
    if (webView.canGoForward){
        webForward.enabled = YES;
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    webStop.enabled = NO;
    [webviewSpinner stopAnimating];
    if (webView.canGoBack){
        webBack.enabled = YES;
    }
    if (webView.canGoForward){
        webForward.enabled = YES;
    }
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
