//
//  JHWebController.m
//  NativeApp
//
//  Created by JiangJiahao on 2018/10/10.
//  Copyright © 2018 JiangJiahao. All rights reserved.
//

#import "JHWebController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "JHWKCookieWebview.h"

@interface JHWebController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic) JHWKCookieWebview *webView;

@property (nonatomic) NSString *url;

@property (nonatomic) UIProgressView *progressView;

@end

@implementation JHWebController
+ (JHWebController *)createJHWebController:(NSString *)url {
    JHWebController *controller = [[JHWebController alloc] init];
    [controller setUrl:url];
    return controller;
}

- (void)setUrl:(NSString *)url {
    if (![url hasPrefix:@"http"] && ![url hasPrefix:@"https"]) {
        url = [NSString stringWithFormat:@"http:%@",url];
    }
    
    _url = url;
}

- (NSString *)controllerTitle {
    if (self.JHWebControllerTitle) {
        return self.JHWebControllerTitle;
    }
    return @"";
}

- (void)updateTitle:(NSString *)title {
    if (self.JHWebControllerTitle) {
        return;
    }
    
    [self.navigationItem setTitle:title];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self addWebView];
    [self addUserAgent];
    [self addProgressView];
    
    [self addObserver];
    
    [self loadUrl];
}

- (void)addUserAgent {
    if (self.customUA) {
        if ([[UIDevice currentDevice].systemVersion floatValue] > 9.0) {
            [_webView setCustomUserAgent:self.customUA];
        } else {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.customUA, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        }
        return;
    }
    
    [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id resultStr, NSError * _Nullable error) {
        NSString *userAgent = resultStr;
        NSString *newUserAgent = [userAgent stringByAppendingString:@" TapDB"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // ios9
        [_webView setCustomUserAgent:newUserAgent];
        
    }];
}

- (void)addObserver {
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:0
                      context:nil];
    
    //添加监测网页标题title的观察者
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

//kvo 监听进度
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == _webView) {
        [self updateProgress:_webView.estimatedProgress animate:YES];
    }else if([keyPath isEqualToString:@"title"] && object == _webView){
        [self updateTitle:_webView.title];
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)addWebView {
    self.webView = [[JHWKCookieWebview alloc] initWithFrame:self.view.frame configuration:[WKWebViewConfiguration new] useRedirectCookie:YES];
    [_webView setUIDelegate:self];
    [_webView setNavigationDelegate:self];
    
    [self.view addSubview:_webView];
    [_webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // AutoLayout
    [[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0] setActive:YES];
}

- (void)addProgressView {
    self.progressView = [[UIProgressView alloc] init];
    [_progressView setProgressTintColor:[UIColor greenColor]];
    [_progressView setTrackTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:_progressView];
    [_progressView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // AutoLayout
    [[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:3.0] setActive:YES];

    
    [self updateProgress:0.1 animate:NO];
}

- (void)updateProgress:(CGFloat)progress animate:(BOOL)animate{
    [self.progressView setProgress:progress animated:animate];
    if (progress >= 1.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.progressView setProgress:0.0 animated:NO];
            [self.progressView setHidden:YES];
        });
    }else {
        [self.progressView setHidden:NO];
    }
}

- (void)loadUrl {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    
    [_webView loadRequest:request];
}

//- (void)goBack:(id)sender {
//    if (_webView.canGoBack) {
//        [_webView goBack];
//        return;
//    }
//
//    [super goBack:sender];
//}

#pragma mark - delegate
// 开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}


// 加载失败
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void)dealloc {
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
}
@end
