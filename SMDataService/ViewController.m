//
//  ViewController.m
//  SMDataService
//
//  Created by 朱思明 on 15/11/17.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 创建新闻列表网络请求对象
    if (_newsDataService == nil) {
        _newsDataService = [[NewsDataService alloc] init];
    }
    
    // 开始请求数据
    [_newsDataService requestNewListWithParamsBlcok:^{
        // 设置请求参数
        _newsDataService.type = 1;
    } finishBlock:^(NSArray<NewModel *> *result) {
        // 请求成功
        NSLog(@"result:%@",result);
    } failureBlock:^(NSError *error) {
        // 请求失败
        NSLog(@"error:%@",error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
