//
//  NewsDataService.h
//  SMDataService
//
//  Created by 朱思明 on 15/11/17.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//

#import "SMDataService.h"
#import "NewModel.h"
typedef void(^NewListBlock)(NSArray<NewModel *> *result);          // 请求成功返回新闻列表数据

@interface NewsDataService : SMDataService


@property (nonatomic, assign) int type;    // 请求数据的类型 1：为新闻

/*
 *  @params
 *  paramsBlock     在block块中设置请求参数
 *  finishBlock     请求成功回调的block
 *  failureBlock    请求失败回调的block
 */
- (void)requestNewListWithParamsBlcok:(SetParamsBlock)paramsBlock
                          finishBlock:(NewListBlock)finishBlock
                         failureBlock:(FailureBlock)failureBlock;
@end
