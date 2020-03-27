//
//  ViewController.m
//  SimpleComponentsDemo
//
//  Created by JiangJiahao on 2019/11/1.
//  Copyright © 2019 JiangJiahao. All rights reserved.
//

#import "ViewController.h"

#import "JHWebImageView.h"
#import "JHAsyncHttp.h"
#import "JHDelayBlock.h"
#import "JHWebController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testImageView];
    [self testHTTP];
    [self testDelayBlock];
    [self testWebcontroller];
}

- (void)testImageView {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *testBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 200)];
    [testBgView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:testBgView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 50, 150, 25)];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"1、图片测试"];
    [testBgView addSubview:title];
    
    // web image
    JHWebImageView *baiduImageView = [[JHWebImageView alloc] initWithFrame:CGRectMake(100, 90, 100, 50)];
    [baiduImageView setContentMode:UIViewContentModeScaleAspectFit];
    [baiduImageView setImageWithUrl:@"https://www.baidu.com/img/baidu_resultlogo@2.png"];
    [testBgView addSubview:baiduImageView];
    
    // local image
    JHWebImageView *googleImageView = [[JHWebImageView alloc] initWithFrame:CGRectMake(250, 90, 100, 50)];
    [googleImageView setContentMode:UIViewContentModeScaleAspectFit];
    [googleImageView setImageWithUrl:@"google.png"];
    [testBgView addSubview:googleImageView];
}

- (void)testHTTP {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *testBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 230, screenSize.width, 200)];
    [testBgView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:testBgView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 150, 25)];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"2、HTTP请求测试"];
    [testBgView addSubview:title];
    
    // textview
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 75, screenSize.width, 105)];
    [textView setBackgroundColor:[UIColor whiteColor]];
    [testBgView addSubview:textView];
    
    [JHAsyncHttp httpGet:@"http://ip-api.com/json" requestParams:nil params:nil callBack:^(JHHttpResult *result) {
        [textView setText:[NSString stringWithFormat:@"请求成功：%@",result.resultDic]];
    } failedCallback:^(JHHttpResult *result) {
        if (result.error) {
            [textView setText:[NSString stringWithFormat:@"请求错误：%@",result.error.localizedDescription]];
            return ;
        }
    }];
}

- (void)testDelayBlock {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *testBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 455, screenSize.width, 150)];
    [testBgView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:testBgView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 150, 25)];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"3、延迟block测试"];
    [testBgView addSubview:title];
    
    // textview
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 65, screenSize.width, 65)];
    [textView setBackgroundColor:[UIColor whiteColor]];
    [testBgView addSubview:textView];
    
    performBlockAfterDelay(5, ^{
        [textView setText:@"延迟5s，执行完毕"];
    });
}

- (void)testWebcontroller {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *testBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 620, screenSize.width, 150)];
    [testBgView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:testBgView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 150, 25)];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"4、浏览器测试"];
    [testBgView addSubview:title];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 90, 200, 50)];
    [button setTitle:@"www.baidu.com" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openWebcontroller) forControlEvents:UIControlEventTouchUpInside];
    [testBgView addSubview:button];
}

- (void)openWebcontroller {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[JHWebController createJHWebController:@"https:www.baidu.com"]];
    [navController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
