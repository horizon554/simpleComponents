//
//  HttpRequest.m
//
//  Created by JiangJiahao on 2018/3/9.
//  Copyright © 2018年 JiangJiahao. All rights reserved.
//

#import "JHHttpRequest.h"

@implementation JHHttpRequest

//! GET参数拼接
+ (NSString *)connectUrl:(NSString *)url params:(NSDictionary *)params {
    if (!params || params.count == 0) {
        return url;
    }
    
    // 初始化参数变量
   __block NSString *str = @"?";
    
    // 快速遍历参数数组
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *strObj = @"";
        if ([obj isKindOfClass:[NSNumber class]]) {
            strObj = [NSString stringWithFormat:@"%@",(NSNumber *)obj];
        }else {
            strObj = obj;
        }
        
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"="];
        str = [str stringByAppendingString:strObj];
        str = [str stringByAppendingString:@"&"];
    }];

    // 处理多余的&以及返回含参url
    if (str.length > 1) {
        // 去掉末尾的&
        str = [str substringToIndex:str.length - 1];
        // 返回含参url
        return [url stringByAppendingString:str];
    }
    
    return url;
}

// POST请求参数拼接
+ (NSString *)postStringWithParams:(NSDictionary *)params {
    // 初始化参数变量
    __block NSString *str = @"";
    
    if (!params || params.count == 0) {
        return str;
    }
    
    // 快速遍历参数数组
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"＝"];
        str = [self URLEncodedString:[str stringByAppendingString:obj]];
        str = [str stringByAppendingString:@"&"];
    }];
    
    // 处理多余的&以及返回含参url
    if (str.length > 1) {
        // 去掉末尾的&
        str = [str substringToIndex:str.length - 1];
    }
    
    return str;

}

+ (NSString *)cookieStringForUrl:(NSString *)url {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
    __block NSString *cookiedStr = @"";
    if (cookies.count > 0) {
        [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *oneCookie, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cookiedStr.length > 0) {
                cookiedStr = [cookiedStr stringByAppendingString:[NSString stringWithFormat:@";%@=%@",oneCookie.name,oneCookie.value]];
            }else {
                cookiedStr = [NSString stringWithFormat:@"%@=%@",oneCookie.name,oneCookie.value];
            }
        }];
    }
    
    return cookiedStr;
}

+ (NSString *)URLEncodedString:(NSString *)string
{
    NSString *unencodedString = string;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

@end
