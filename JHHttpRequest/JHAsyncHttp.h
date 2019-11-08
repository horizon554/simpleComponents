//
//  AsyncHttp.h
//
//  Created by JiangJiahao on 2018/3/9.
//  Copyright © 2018年 JiangJiahao. All rights reserved.
//  简单HTTP请求

#import <Foundation/Foundation.h>
#import "JHHttpResult.h"

extern NSString *const JH_TIMEOUTKEY;
extern NSString *const JH_HTTPMETHODKEY;
extern NSString *const JH_HTTPBODYKEY;
extern NSString *const JH_DATAFORMAT;


typedef void(^CallBackBlock)(JHHttpResult *result);
typedef void(^GetAllCallBack)(NSArray *resultArr,BOOL successAll);


@interface JHAsyncHttp : NSObject
- (void)stopTask;
+ (NSString *)getRealUrl:(NSString *)url;
// GET
+ (JHAsyncHttp *)httpGet:(NSString *)urlStr params:(NSDictionary *)params callBack:(CallBackBlock)callBackBlock;

/**
 多个get请求并发，同时返回

 @param urlStrArr URL数组
 @param paramsDicArr 参数数组
 @param callback 回掉
 */
+ (void)httpGetAll:(NSArray *)urlStrArr params:(NSArray *)paramsDicArr callback:(GetAllCallBack)callback;


// POST
+ (JHAsyncHttp *)httpPost:(NSString *)urlStr params:(NSDictionary *)params callBack:(CallBackBlock)callBackBlock;

#pragma mark - tool
+ (NSDictionary *)dictionaryFromJsonData:(NSData *)data;
+ (NSString *)jsonString:(NSDictionary *)dictionary;
@end
