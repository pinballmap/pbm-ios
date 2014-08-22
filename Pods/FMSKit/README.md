# FMSKit

# FMSDrawer Usage
```
// AppDelegate.m
_drawer = [FMSDrawer sharedInstance];
[_drawer setDataSource:self];
[_drawer setDelegate:self];
[_drawer setParentView:(UINavigationController *)_window.rootViewController];
```

# Reusable WebView Usage
```
ReuseWebView *webView = [[ReuseWebView alloc] 
	initWithURL:[NSURL URLWithString:@"http://github.com/blog"]];
webView.webTitle = @"GitHub Blog";
// Present webView within a navigation controller.
[self presentViewController:[[UINavigationController alloc] 
	initWithRootViewController:webView] animated:YES completion:nil];

```
