//
//  JHWKCookieWebview+CookiesHandle.m
//  NativeApp
//
//  Created by JiangJiahao on 2019/4/3.
//  Copyright © 2019 JiangJiahao. All rights reserved.
//

#import "JHWKCookieWebview+CookiesHandle.h"

@implementation JHWKCookieWebview (CookiesHandle)

- (void)syncCookies:(NSURLRequest *)request task:(nullable NSURLSessionTask *)task complitionHandle:(void (^)(NSURLRequest * _Nonnull))complitionHandle {
    NSMutableURLRequest *newRequest = request.mutableCopy;
    __block NSMutableArray *cookiesArr = [NSMutableArray array];
    
    if (task) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] getCookiesForTask:task completionHandler:^(NSArray<NSHTTPCookie *> * _Nullable cookies) {
            if (cookies && cookies.count > 0) {
                [cookiesArr addObjectsFromArray:cookies];
                NSDictionary *cookieDic = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArr];
                if ([cookieDic objectForKey:@"Cookie"]) {
                    [newRequest addValue:[cookieDic objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
                }
            }
            
        }];
    }else if (request.URL) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
        if (cookies && cookies.count > 0) {
            [cookiesArr addObjectsFromArray:cookies];
        }
        
        NSDictionary *cookieDic = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArr];
        if ([cookieDic objectForKey:@"Cookie"]) {
            [newRequest addValue:[cookieDic objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        }
    }
    
    complitionHandle(newRequest);
}

- (void)syncCookiesInJS:(nullable NSURLRequest *)request {
    if (request.URL) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
        NSString *script = [self jsCookiesString:cookies];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [[[self configuration] userContentController] addUserScript:cookieScript];
    }else if ([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSString *script = [self jsCookiesString:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [[[self configuration] userContentController] addUserScript:cookieScript];
    }
}

- (NSString *)jsCookiesString:(NSArray *)cookies {
    NSString *result = @"";
    NSLocale *CNLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:CNLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];

    for (NSHTTPCookie *cookie in cookies) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"document.cookie='%@=%@;domain=%@;path=%@;",cookie.name,cookie.value,cookie.domain,cookie.path]];
        if (cookie.expiresDate) {
            result = [result stringByAppendingString:[NSString stringWithFormat:@"expires=%@",[dateFormatter stringFromDate:cookie.expiresDate]]];
        }
        
        if (cookie.isSecure) {
            result = [result stringByAppendingString:@"secure;"];
        }
        
        result = [result stringByAppendingString:@"';"];
    }
    
    return result;
}

@end
