//
//  NewsDataService.m
//  SMDataService
//
//  Created by 朱思明 on 15/11/17.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//
#import "NewsDataService.h"

@implementation NewsDataService

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.httpMethod = @"GET";
        self.api_url = @"http://123.57.246.163:8063/api/New";
    }
    return self;
}

/*
 *  @params
 *  paramsBlock     在block块中设置请求参数
 *  finishBlock     请求成功回调的block
 *  failureBlock    请求失败回调的block
 */
- (void)requestNewListWithParamsBlcok:(SetParamsBlock)paramsBlock
                          finishBlock:(NewListBlock)finishBlock
                         failureBlock:(FailureBlock)failureBlock
{
    [self requestDataWithParamsBlcok:^{
        // 设置参数
        if (paramsBlock != nil) {
            paramsBlock();
        }
    } finishBlock:^(id result) {
        if (finishBlock != nil) {
            if ([result[@"code"] intValue] == 1000) {
                // 把数据整理成数据原型
                NSArray * resultArray = result[@"result"];
                NSMutableArray * newModels = [[NSMutableArray alloc] init];
                for (NSDictionary * dic in resultArray) {
                    NewModel * newModel = [[NewModel alloc] initWithContentDic:dic];
                    
                    [newModels addObject:newModel];
                }
                finishBlock(newModels);
            } else {
                NSError *error = [NSError errorWithDomain:result[@"errMsg"] code:[result[@"code"] intValue] userInfo:nil];
                if (failureBlock != nil) {
                    failureBlock(error);
                }
            }
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}


@end
