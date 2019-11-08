//
//  JHDelayBlock.h
//  NativeApp
//
//  Created by JiangJiahao on 2019/5/29.
//  Copyright © 2019 JiangJiahao. All rights reserved.
//  延迟执行Block,可取消

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JHDelayBlockHandle)(BOOL cancel);

static JHDelayBlockHandle performBlockAfterDelay(CGFloat seconds,dispatch_block_t block) {
    if (nil == block) {
        return nil;
    }
    
    __block JHDelayBlockHandle delayHandle = ^(BOOL cancel){
        if (NO == cancel && nil != block) {
            dispatch_async(dispatch_get_main_queue(), block);
        }
        
        delayHandle = nil;
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (nil != delayHandle) {
            delayHandle(NO);
        }
    });
    
    return delayHandle;
}

static void cancelDelayBlock(JHDelayBlockHandle delayHandle) {
    if (nil == delayHandle) {
        return;
    }
    
    delayHandle(YES);
}



@interface JHDelayBlock : NSObject

@end

NS_ASSUME_NONNULL_END
