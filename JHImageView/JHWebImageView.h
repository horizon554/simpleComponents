//
//  JHWebImageView.h
//
//  Created by JiangJiahao on 2019/10/21.
//  简单Imageview，支持网络图片与本地图片

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHWebImageView :UIImageView
- (void)setImageWithUrl:(NSString *)imageUrl;
@end

NS_ASSUME_NONNULL_END
