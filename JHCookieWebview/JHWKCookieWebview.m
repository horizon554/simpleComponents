//
//  JHWKCookieWebview.m
//  NativeApp
//
//  Created by JiangJiahao on 2019/4/3.
//  Copyright © 2019 JiangJiahao. All rights reserved.
//

#import "JHWKCookieWebview.h"
#import "JHWKCookieWebview+CookiesHandle.h"

@interface JHWKCookieWebview ()<NSURLSessionTaskDelegate>

@property (nonatomic) BOOL useRedirectCookieHandling;

@end

@implementation JHWKCookieWebview

- (id)init {
    self = [super init];
    if (self) {
        self.useRedirectCookieHandling = NO;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration useRedirectCookie:(BOOL)useRedirectCookie {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.useRedirectCookieHandling = useRedirectCookie;
    }
    
    return self;
}

- (WKNavigation *)loadRequest:(NSURLRequest *)request {
    if (!self.useRedirectCookieHandling) {
        return [super loadRequest:request];
    }
    
    [self requestWithCookieHandle:request success:^(NSURLRequest *newRequest, NSHTTPURLResponse *response, NSData *data,NSURLSession *session) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [session invalidateAndCancel];
            [self syncCookiesInJS:nil];
            if (data && response) {
                [self webViewLoad:data response:response];
            }else {
                [self syncCookies:newRequest task:nil complitionHandle:^(NSURLRequest * _Nonnull resultRequest) {
                    [super loadRequest:resultRequest];
                }];
            }
        });
    } fail:^(NSURLSession *session){
        dispatch_async(dispatch_get_main_queue(), ^{
            [session invalidateAndCancel];
            [self syncCookies:request task:nil complitionHandle:^(NSURLRequest * _Nonnull newRequest) {
                [super loadRequest:newRequest];
            }];
        });
    }];
    
    return nil;
}

- (void)requestWithCookieHandle:(NSURLRequest *)request success:(void(^)(NSURLRequest *newRequest,NSHTTPURLResponse *response,NSData *data,NSURLSession *session))successBlock fail:(void(^)(NSURLSession *session))failBlock{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    // delegate 强引用 需要手动释放
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failBlock(session);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse) {
            NSInteger code = httpResponse.statusCode;
            if (code == 200) {
                successBlock(request,httpResponse,data,session);
            }else if (code > 300 && code < 400) {
                // redirect
                NSString *location = httpResponse.allHeaderFields[@"Location"];
                if (!location || location.length <= 0) {
                    failBlock(session);
                    return;
                }
                NSURL *redirectUrl = [NSURL URLWithString:location];
                NSURLRequest *newRequest = [NSURLRequest requestWithURL:redirectUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
                
                successBlock(newRequest,nil,nil,session);

            }
            else {
                successBlock(request,httpResponse,data,session);

            }
        }
    }];
    
    [task resume];
}

- (WKNavigation *)webViewLoad:(NSData *)data response:(NSURLResponse *)response {
    if (!response.URL) {
        return nil;
    }
    
    NSString *encode = response.textEncodingName?:@"utf8";
    NSString *mineType = response.MIMEType?:@"text/html";
    
    return [self loadData:data MIMEType:mineType characterEncodingName:encode baseURL:response.URL];
}

#pragma mark - delegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    [self syncCookies:request task:nil complitionHandle:^(NSURLRequest * _Nonnull newRequest) {
        completionHandler(newRequest);
    }];
}
@end
