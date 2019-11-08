//
//  JHHttpImageDownloader.h
//
//  Created by JiangJiahao on 2019/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^jhDownloadImageCallback)(BOOL success);

@interface JHHttpImageDownloader : NSObject
+ (void)downloadImage:(NSString *)url callback:(jhDownloadImageCallback)callback;
@end

NS_ASSUME_NONNULL_END
