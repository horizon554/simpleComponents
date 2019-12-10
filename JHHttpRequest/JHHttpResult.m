//
//  HttpResult.m
//
//  Created by JiangJiahao on 2018/3/9.
//  Copyright © 2018年 JiangJiahao. All rights reserved.
//

#import "JHHttpResult.h"

@implementation JHHttpResult

- (void)setData:(NSData *)data {
    _data = data;
    [self setResultDic:[self dictionaryFromJsonData:data]];
}

- (NSDictionary *)dictionaryFromJsonData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    
    return nil;
}

@end
