//
//  JHHttpImageDownloader.m
//
//  Created by JiangJiahao on 2019/10/21.
//

#import "JHHttpImageDownloader.h"
#import "JHImageHelper.h"

@implementation JHHttpImageDownloader

+ (NSString *)saveFilePath{
    return [JHImageHelper imagePath];
}

+ (NSString *)saveFileName:(NSString *)url {
    NSString *imageName = [JHImageHelper imageNameWithUrl:url];
    return imageName;
}

+ (void)downloadImage:(NSString *)url callback:(jhDownloadImageCallback)callback {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *download = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            callback(!error);
            return;
        }
        
        // TODO
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *file = [[self saveFilePath] stringByAppendingPathComponent:[self saveFileName:url]];
        NSString *file = [caches stringByAppendingPathComponent:[self saveFileName:url]];
        NSFileManager *mgr = [NSFileManager defaultManager];
        [mgr moveItemAtPath:location.path toPath:file error:nil];
        callback(YES);
    }];
    [download resume];
}


@end
