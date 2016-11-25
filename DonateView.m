#import "DonateView.h"

@interface DonateView () <UIWebViewDelegate>

@property (weak) IBOutlet UIWebView *mainWebView;

@end

@implementation DonateView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Donate";
    
    self.mainWebView.delegate = self;

    NSString *donateHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"donate" ofType:@"html" inDirectory:@"."] encoding:NSUTF8StringEncoding error:nil];
    
    [self.mainWebView loadHTMLString:donateHTML baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"donate" ofType:@"html" inDirectory:@"."]]];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
