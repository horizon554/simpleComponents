//
//  JHImageCache.m
//
//  Created by JiangJiahao on 2019/10/21.
//

#import "JHImageCache.h"

@interface JHImageCache ()

@property (nonatomic) NSCache *cache;
@end

static JHImageCache *cache_instance;

@implementation JHImageCache
+ (JHImageCache *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache_instance = nil;
        cache_instance = [[JHImageCache alloc] init];
    });
    
    return cache_instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupCache];
    }
    
    return self;
}

- (void)setupCache {
    self.cache = [[NSCache alloc] init];
    [self.cache setCountLimit:100];
}

+ (void)setObject:(id)obj forKey:(id)key {
    JHImageCache *xdCache = [self shareInstance];
    [xdCache.cache setObject:obj forKey:key];
}

+ (id)objectForKey:(id)key {
    JHImageCache *xdCache = [self shareInstance];
    return [xdCache.cache objectForKey:key];
}

@end
