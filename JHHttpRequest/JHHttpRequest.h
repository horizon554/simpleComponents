//
//  HttpRequest.h
//
//  Created by JiangJiahao on 2018/3/9.
//  Copyright © 2018年 JiangJiahao. All rights reserved.
//  Httpq请求封装

#import <Foundation/Foundation.h>

@interface JHHttpRequest : NSObject

//! GET参数拼接
+ (NSString *)connectUrl:(NSString *)url params:(NSDictionary *)params;

// POST请求参数拼接
+ (NSString *)postStringWithParams:(NSDictionary *)params;

// cookie
+ (NSString *)cookieStringForUrl:(NSString *)url;

@end
