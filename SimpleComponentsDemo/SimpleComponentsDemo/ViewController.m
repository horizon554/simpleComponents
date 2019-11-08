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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testImageView];
    [self testHTTP];
    [self testDelayBlock];
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
    
    [JHAsyncHttp httpGet:@"http://ip.taobao.com/service/getIpInfo.php" params:@{@"ip":@"192.168.1.1"} callBack:^(JHHttpResult *result) {
        if (result.error) {
            [textView setText:[NSString stringWithFormat:@"请求错误：%@",result.error.localizedDescription]];
            return ;
        }
        
        NSDictionary *dataDic = [JHAsyncHttp dictionaryFromJsonData:result.data];
        [textView setText:[NSString stringWithFormat:@"请求成功：%@",dataDic]];
    }];
}

- (void)testDelayBlock {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *testBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 460, screenSize.width, 150)];
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


@end
