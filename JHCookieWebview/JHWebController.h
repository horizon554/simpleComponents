//
//  JHWebController.h
//  NativeApp
//
//  Created by JiangJiahao on 2018/10/10.
//  Copyright © 2018 JiangJiahao. All rights reserved.
//  简单的网页浏览器

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHWebController : UIViewController

@property (nonatomic) NSString *JHWebControllerTitle;
@property (nonatomic) NSString *customUA;
+ (JHWebController *)createJHWebController:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
