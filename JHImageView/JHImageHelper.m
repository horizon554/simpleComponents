//
//  JHImageHelper.m
//
//  Created by JiangJiahao on 2019/10/21.
//

#import "JHImageHelper.h"
#include <CommonCrypto/CommonCrypto.h>


@implementation JHImageHelper
+ (NSString *)imagePath {
    // caches
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return caches;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docPath = [paths objectAtIndex:0];
//    NSString *imagePath = [NSString stringWithFormat:@"%@/taptapImages",docPath];
//    BOOL isDir = YES;
//    BOOL isDirExist = [fileManager fileExistsAtPath:imagePath isDirectory:&isDir];
//    if (!isDirExist) {
//        BOOL createDir = [fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
//        if (!createDir) {
//            // create FAIL!
//        }
//    }
//
//    return imagePath;
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    if (@available(iOS 10.0, *)) {
        CGFloat scale = [UIScreen mainScreen].scale;
        UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
        [format setScale:scale];
        [format setOpaque:YES];
        
        UIGraphicsImageRenderer *imageRender = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
        UIImage *resultImage = [imageRender imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [img drawInRect:CGRectMake(0, 0, size.width , size.height)];
        }];
    
        return resultImage;
    }else {
        return img;
    }
}

+ (NSString *)imageNameWithUrl:(NSString *)url {
    if (!url || url.length <= 0) {
        return nil;
    }
    NSArray *arr = [url componentsSeparatedByString:@"/"];
    NSString *imageName = arr.lastObject;
    
    NSString *fileExt = [imageName pathExtension];
    NSString *pureName = [imageName stringByDeletingPathExtension];
    NSString *md5Name = [self md5String:pureName];
    
    return [NSString stringWithFormat:@"%@.%@",md5Name,fileExt];
}

+ (NSString *)md5String:(NSString *)targetString {
    NSData *targetData = [targetString dataUsingEncoding:NSUTF8StringEncoding];
    return [self md5StringForData:targetData];
}
+ (NSString *)md5StringForData:(NSData *)targetData {
    unsigned char result[16];
    CC_MD5(targetData.bytes, (CC_LONG)targetData.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


#pragma mark - image loader
+ (void)loadImage:(NSString *)imageName resultBlock:(jhImageLoaderResultBlock)block{
    [self loadImage:imageName size:CGSizeZero resultBlock:block];
}

+ (void)loadImage:(NSString *)imageName size:(CGSize)size resultBlock:(jhImageLoaderResultBlock)block{
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",[self imagePath],imageName];
    dispatch_async(imageQueue(), ^{
        NSFileManager *fileManger = [NSFileManager defaultManager];
        
        if (![fileManger fileExistsAtPath:fullPath]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil,imageName);
            });
            return;
        }
        
        NSData *imageData = [fileManger contentsAtPath:fullPath];
        UIImage *image = [UIImage imageWithData:imageData];
        
        // remove alpha chanel
        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
        image = [UIImage imageWithData:jpegData];
        
        if (image) {
            [self decodeImage:image size:size resultBlock:^(UIImage *resultImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(resultImage,imageName);
                });
            }];
            return;
        }
        
        // not decode
        dispatch_async(dispatch_get_main_queue(), ^{
            block(image,imageName);
        });
    });
}

+ (UIImage *)getBundleImage:(NSString *)imageName resultBlock:(jhImageLoaderResultBlock)block{
    return [self getBundleImage:imageName size:CGSizeZero resultBlock:block];
}

+ (UIImage *)getBundleImage:(NSString *)imageName size:(CGSize)size resultBlock:(jhImageLoaderResultBlock)block{
    NSString *type = [imageName pathExtension];
    NSString *name = [imageName stringByDeletingPathExtension];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *tail = @"@2x";
    if (scale == 3) {
        tail = @"@3x";
    }
    
    NSString *realname = [NSString stringWithFormat:@"%@%@",name,tail];
    NSString *path = [[NSBundle mainBundle] pathForResource:realname ofType:type];
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    }
    
    if (!path) {
        // 最后尝试图片名
        NSString *lastImageName = [@"@2x" isEqualToString:tail]?[name stringByAppendingString:@"@3x"]:[name stringByAppendingString:@"@2x"];
        path = [[NSBundle mainBundle] pathForResource:lastImageName ofType:type];
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (block) {
        block(image,imageName);
    }
    
    // original image
    return image;
}

+ (void)decodeImage:(UIImage *)image size:(CGSize)size resultBlock:(jhImageDecodeResultBlock)decodeResultBlock{
    if (!image) {
        decodeResultBlock(nil);
        return;
    }
    dispatch_async(imageQueue(), ^{
        CGSize imageSize = size;
        
        @autoreleasepool {
            UIImage *newImage = image;
            if (!CGSizeEqualToSize(imageSize, CGSizeZero)) {
                CGFloat scale = [UIScreen mainScreen].scale;
                imageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
                newImage = [self scaleToSize:image size:imageSize];
            }else {
                imageSize = newImage.size;
            }
            
            CGImageRef sourceImageRef = newImage.CGImage;
            
            CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(sourceImageRef) & kCGBitmapAlphaInfoMask;
            
            BOOL hasAlpha = NO;
            if (alphaInfo == kCGImageAlphaPremultipliedLast ||
                alphaInfo == kCGImageAlphaPremultipliedFirst ||
                alphaInfo == kCGImageAlphaLast ||
                alphaInfo == kCGImageAlphaFirst) {
                hasAlpha = YES;
            }
            
            CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
            bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
            
            CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, colorSpaceGetDeviceRGB(), bitmapInfo);
            if (!context) {
                
            }
            
            CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), sourceImageRef); // decode
            CGContextSetAlpha(context, 1.0);
            CGImageRef bitmapImage = CGBitmapContextCreateImage(context);
            // release
            CFRelease(context);
            
            UIImage *resultImage = [UIImage imageWithCGImage:bitmapImage];
            CFRelease(bitmapImage);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                decodeResultBlock(resultImage);
            });
        }
    });
}

CGColorSpaceRef colorSpaceGetDeviceRGB() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

dispatch_queue_t imageQueue() {
    static dispatch_queue_t IMAGE_QUEUE;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IMAGE_QUEUE = dispatch_queue_create("image_decode_queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return IMAGE_QUEUE;
}
@end
