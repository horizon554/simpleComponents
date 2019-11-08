//
//  JHImageHelper.h
//
//  Created by JiangJiahao on 2019/10/21.
//  图片处理帮助类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^jhImageLoaderResultBlock)(UIImage *resultImage,NSString *imageName);
typedef void(^jhImageDecodeResultBlock)(UIImage *resultImage);

@interface JHImageHelper : NSObject
+ (NSString *)imageNameWithUrl:(NSString *)url;
+ (NSString *)imagePath;

+ (void)loadImage:(NSString *)imageName resultBlock:(jhImageLoaderResultBlock)block;
+ (UIImage *)getBundleImage:(NSString *)imageName resultBlock:(jhImageLoaderResultBlock)block;
@end

NS_ASSUME_NONNULL_END
