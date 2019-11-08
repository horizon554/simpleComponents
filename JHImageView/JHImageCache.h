//
//  JHImageCache.h
//
//  Created by JiangJiahao on 2019/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHImageCache : NSObject
+ (JHImageCache *)shareInstance;
+ (void)setObject:(id)obj forKey:(id)key;
+ (id)objectForKey:(id)key;
@end

NS_ASSUME_NONNULL_END
