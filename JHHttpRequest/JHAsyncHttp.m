//
//  AsyncHttp.m
//
//  Created by JiangJiahao on 2018/3/9.
//  Copyright © 2018年 JiangJiahao. All rights reserved.
//

#import "JHAsyncHttp.h"
#import "JHHttpRequest.h"

NSString *const JH_TIMEOUTKEY = @"timeoutInterval";
NSString *const JH_HTTPMETHODKEY = @"HTTPMethod";
NSString *const JH_HTTPBODYKEY = @"HTTPBody";
NSString *const JH_DATAFORMAT = @"JH_DATAFORMAT";

@interface JHAsyncHttp ()

@property (nonatomic,copy) CallBackBlock callBackBlock;
@property (nonatomic) NSURLSessionTask *task;
@property (nonatomic) JHAsyncHttp *httpSelf;

@end

@implementation JHAsyncHttp

+ (NSString *)getRealUrl:(NSString *)url {
    return url;
}

- (void)stopTask {
    self.httpSelf = nil;
    
    if(self.task) {
        [self.task cancel];
    }
    
    if(self.callBackBlock) {
        self.callBackBlock = nil;
    }
}

// GET
+ (JHAsyncHttp *)httpGet:(NSString *)urlStr params:(NSDictionary *)params callBack:(CallBackBlock)callBackBlock{
    NSString *realUrl = [self getRealUrl:urlStr];
    __block JHAsyncHttp *http = [[JHAsyncHttp alloc] init];
    http.callBackBlock = callBackBlock;
    http.httpSelf = http;
    realUrl = [JHHttpRequest connectUrl:realUrl params:params];
    NSURL *url = [NSURL URLWithString:realUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
//    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    
    __weak typeof (http) weakHttp = http;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof (http) strongHttp = weakHttp;
        if (!strongHttp.callBackBlock) {
            return;
        }
        
        JHHttpResult *result = [[JHHttpResult alloc] init];
        [result setData:data];
        [result setResponse:response];
        [result setError:error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongHttp.callBackBlock) {
                strongHttp.callBackBlock(result);
            }
            strongHttp.httpSelf = nil;
        });
        
    }];
    
    [dataTask resume];
    http.task = dataTask;
    
    return http;
}

// POST
+ (JHAsyncHttp *)httpPost:(NSString *)urlStr params:(NSDictionary *)params callBack:(CallBackBlock)callBackBlock{
    NSString *realUrl = [self getRealUrl:urlStr];

    JHAsyncHttp *http = [[JHAsyncHttp alloc] init];
    http.callBackBlock = callBackBlock;
    http.httpSelf = http;
    NSURL *url = [NSURL URLWithString:realUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:15];
    // 默认json
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // 参数
    if ([params objectForKey:JH_HTTPBODYKEY]) {
        NSString *paramsStr = [self jsonString:[params objectForKey:JH_HTTPBODYKEY]];

        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if ([params objectForKey:JH_TIMEOUTKEY]) {
        NSNumber *timeOut = [params objectForKey:JH_TIMEOUTKEY];
        [request setTimeoutInterval:[timeOut doubleValue]];
    }
    
    if ([params objectForKey:JH_DATAFORMAT] && [[params objectForKey:JH_DATAFORMAT] isEqualToString:@"form"]) {
        [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSString *paramsStr = [JHHttpRequest postStringWithParams:[params objectForKey:JH_HTTPBODYKEY]];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    __weak typeof (http) weakHttp = http;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof (http) strongHttp = weakHttp;
        if (!strongHttp.callBackBlock) {
            return;
        }
        
        JHHttpResult *result = [[JHHttpResult alloc] init];
        [result setData:data];
        [result setResponse:response];
        [result setError:error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongHttp.callBackBlock) {
                strongHttp.callBackBlock(result);
            }
            strongHttp.httpSelf = nil;
        });
        
    }];
    
    [dataTask resume];
    http.task = dataTask;
    
    return http;
}

+ (void)httpGetAll:(NSArray *)urlStrArr params:(NSArray *)paramsDicArr callback:(GetAllCallBack)callback{
    if (!urlStrArr || urlStrArr.count <= 0) {
        if (callback) {
            callback(nil,NO);
        }
        return;
    }
    
    // 初始化保存的数据
    __block NSMutableArray *resultDataArr = [NSMutableArray array];
    for (NSInteger index = 0; index < urlStrArr.count; index ++) {
        [resultDataArr addObject:@{}];
    }
    
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    [urlStrArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *params = [paramsDicArr objectAtIndex:idx];
        dispatch_group_enter(downloadGroup);
        [JHAsyncHttp httpGet:obj params:params callBack:^(JHHttpResult *result) {
            if (result.error) {
                // 失败
                dispatch_group_leave(downloadGroup);
                return;
            }
            
            if (!result.data) {
                dispatch_group_leave(downloadGroup);
                return;
            }
            
            NSDictionary *dataDic = [self dictionaryFromJsonData:result.data];
            if ([dataDic objectForKey:@"code"] && [[dataDic objectForKey:@"code"] intValue] != 200) {
                dispatch_group_leave(downloadGroup);
                return;
            }
            
            // success
            [resultDataArr replaceObjectAtIndex:idx withObject:dataDic];
            dispatch_group_leave(downloadGroup);
        }];
    }];
    
    
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        BOOL success = YES;
        for (NSDictionary *dataDic in resultDataArr) {
            if (dataDic.allKeys.count <= 0) {
                success = NO;
            }
        }
        if (callback) {
            callback(resultDataArr,success);
        }
    });
}

#pragma mark - tool
+ (NSDictionary *)dictionaryFromJsonData:(NSData *)data {
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    
    return nil;
}

+ (NSString *)jsonString:(NSDictionary *)dictionary {
    NSError *error = nil;
    NSData *jsonData = nil;
    if (!dictionary) {
        return nil;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *keyString = nil;
        NSString *valueString = nil;
        if ([key isKindOfClass:[NSString class]]) {
            keyString = key;
        }else{
            keyString = [NSString stringWithFormat:@"%@",key];
        }
        
        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            valueString = obj;
        }else if ([obj isKindOfClass:[NSNumber class]]){
            valueString = obj;
        }
        else{
            valueString = [NSString stringWithFormat:@"%@",obj];
        }
        
        [dict setObject:valueString forKey:keyString];
    }];
    jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] == 0 || error != nil) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
