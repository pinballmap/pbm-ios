//
//  AboutView.m
//  PinballMap
//
//  Created by Frank Michael on 4/20/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "AboutView.h"
#import "GAAppHelper.h"
#import "UIAlertView+Application.h"
#import "ContactView.h"
#import "ReuseWebView.h"

@interface AboutView () <UIWebViewDelegate>

@property (weak) IBOutlet UIWebView *mainWebView;

- (IBAction)dismissAbout:(id)sender;
@end

@implementation AboutView

- (void)viewDidLoad{
    [super viewDidLoad];
    self.mainWebView.delegate = self;
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html" inDirectory:@"about_page"]];
    [self.mainWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    UIBarButtonItem *feedback = [[UIBarButtonItem alloc] initWithTitle:@"Feedback" style:UIBarButtonItemStylePlain target:self action:@selector(sendFeedback:)];
    self.navigationItem.rightBarButtonItem = feedback;
    UIBarButtonItem *dismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAbout:)];
    self.navigationItem.leftBarButtonItem = dismiss;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissAbout:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)sendFeedback:(id)sender{
    ContactView *eventContact = (ContactView *)[[self.storyboard instantiateViewControllerWithIdentifier:@"ContactView"] navigationRootViewController];
    eventContact.contactType = ContactTypeAppFeedback;
    [self.navigationController presentViewController:eventContact.parentViewController animated:YES completion:nil];
}
#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString rangeOfString:@"about.html"].location != NSNotFound){
        return true;
    }
    [[UIApplication sharedApplication] openURL:request.URL];
    return false;
}

@end
