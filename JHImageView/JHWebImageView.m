#import "JHWebImageView.h"
#import "JHImageHelper.h"
#import "JHHttpImageDownloader.h"
#import "JHImageCache.h"

@interface JHWebImageView ()

@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *imageName;


@end

@implementation JHWebImageView
- (void)setImageWithUrl:(NSString *)imageUrl {
    if ([imageUrl isEqualToString:self.imageUrl]) {
        return;
    }
    self.imageUrl = imageUrl;
    
    if (![imageUrl hasPrefix:@"http"] && ![imageUrl hasPrefix:@"https"]) {
        self.imageName = imageUrl;
        // 本地图片
        [self loadLocalImage:imageUrl result:^(UIImage *resultImage,NSString *imageName) {
            if (![imageName isEqualToString:self.imageName]) {
                // image changed
                return;
            }
            [self setImage:resultImage];
        }];
        return;
    }
    
    NSString *imageName = [JHImageHelper imageNameWithUrl:imageUrl];
    self.imageName = imageName;
    [self loadImage:imageName result:^(UIImage *resultImage,NSString *imageName) {
        if (![imageName isEqualToString:self.imageName]) {
            // image changed
            return;
        }
        if (resultImage) {
            [self setImage:resultImage];
        }else {
            // 网络下载
            [JHHttpImageDownloader downloadImage:imageUrl callback:^(BOOL success) {
                if (success) {
                    [self loadImage:imageName result:^(UIImage *resultImage,NSString *imageName) {
                        if (![imageName isEqualToString:self.imageName]) {
                            // image changed
                            return;
                        }
                        [self setImage:resultImage];
                    }];
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:nil];
                    });
                }
            }];
        }
    }];
}

// 本地图片
- (void)loadLocalImage:(NSString *)imageName result:(jhImageLoaderResultBlock)resultBlock{
    [JHImageHelper getBundleImage:imageName resultBlock:resultBlock];
}

- (void)loadImage:(NSString *)imageName result:(jhImageLoaderResultBlock)resultBlock{
    UIImage *image = [JHImageCache objectForKey:imageName];
    if (image) {
        resultBlock(image,imageName);
        return;
    }
    
    // 磁盘加载
    [JHImageHelper loadImage:imageName resultBlock:^(UIImage *resultImage,NSString *imageName) {
        if (resultImage) {
            // 缓存
            [JHImageCache setObject:resultImage forKey:imageName];
        }
        resultBlock(resultImage,imageName);
    }];
}

@end
