//
//  CXDataService.m
//  SMDataService
//
//  Created by 朱思明 on 15/11/17.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//

#import "SMDataService.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation SMDataService


- (void)dealloc
{
    if (_isMoreDataTask == YES) {
        // 取消所有为完成任务
        for (NSURLSessionDataTask *dataTask in _dataTasks) {
            [dataTask cancel];
        }
    } else {
        [_dataTask cancel];
    }
}

#pragma mark - 自定义初始化方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 润许使用蜂窝数据
        _allowsCellularAccess = YES;
        _httpMethod = @"GET";
        // 1.初始化基本数据类型的值为：-100
        // 01 获取当前类
        Class myClass = [self class];
        // 02 获取当前类中属性名字的集合
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(myClass, &count);
        // 03 遍历所有的属性
        for (int i = 0; i < count; i++) {
            // 获取当前属性的名字
            objc_property_t property = properties[i];
            const char * char_property_name = property_getName(property);
            // 如果获取到这个属性的名字
            if (char_property_name) {
                // 转换成字符串对象
                NSString *property_name = [[NSString alloc] initWithCString:char_property_name encoding:NSUTF8StringEncoding];
                // 获取当前属性对应的内容
                id value = [self valueForKey:property_name];
                // 判断当前对象是数值对象
                if ([value isKindOfClass:[NSValue class]]) {
                    // 设置默认值：-100
                    [self setValue:@(-100) forKey:property_name];
                }
            }
        }
    }
    return self;
}

#pragma mark - 开始网络请求
- (void)requestDataWithParamsBlcok:(SetParamsBlock)paramsBlock
                       finishBlock:(FinishBlock)finishBlock
                      failureBlock:(FailureBlock)failureBlock
{
    // 1.取消之前的网络请求
    if (_isMoreDataTask == NO) {
        [_dataTask cancel];
    } else {
        if (_dataTasks == nil) {
            // 创建存储多任务数组
            _dataTasks = [[NSMutableArray alloc] init];
        }
    }
    
    // 现实加载进度
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES ;
    
    // 3.添加请求对象参数配置设置block
    if (paramsBlock != nil) {
        paramsBlock();
    }
    
    // 4.设置网络请求
    // 判断请求方式
    // 01 构建请求对象
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setHTTPMethod:_httpMethod];
    [urlRequest setTimeoutInterval:DEFAULT_TIMEOUT];
    NSString *urlString = _api_url;
    // 02 添加参数
    if ([self.httpMethod caseInsensitiveCompare:@"GET"] == NSOrderedSame || [self.httpMethod caseInsensitiveCompare:@"PUT"] == NSOrderedSame || [self.httpMethod caseInsensitiveCompare:@"DELETE"] == NSOrderedSame) {
        // 03 如果是get方法(忽略大小写区比较)
        // 获取当前的参数
        NSDictionary *attributes = [self getMyClassAttributeNameAndValue];
        // 把参数拼接到路径的后面
        for (int i = 0;i < attributes.count ; i++) {
            NSString *key = attributes.allKeys[i];
            if (i == 0) {
                urlString = [NSString stringWithFormat:@"%@?%@=%@",urlString,key,attributes[key]];
            } else {
                urlString = [NSString stringWithFormat:@"%@&%@=%@",urlString,key,attributes[key]];
            }
            
        }
        // 设置请求对象的URL地址
        urlRequest.URL = [NSURL URLWithString:urlString];
    } else if ([self.httpMethod caseInsensitiveCompare:@"POST"] == NSOrderedSame ) {
        // 03 如果是POST请求
        // 设置请求对象的URL地址
        urlRequest.URL = [NSURL URLWithString:urlString];
        // 获取当前的参数
        NSDictionary *attributes = [self getMyClassAttributeNameAndValue];
        // 把参数添加到请求体中
        [urlRequest setHTTPBody:[self getDataStringWithParams:attributes]];

    }
    
    // 03 创建网络会话对象
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.allowsCellularAccess = _allowsCellularAccess;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config];
    // 04 开始创建网络任务对象
    _dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 移除当前已经完成任务
            if (_isMoreDataTask == YES) {
                [_dataTasks removeObject:_dataTask];
            }
            
            if (error == nil) {
                // 打印测试
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",string);
                if (data != nil) {
                    // JSON解析
                    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    finishBlock(result);
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO ;
                
            } else {
                NSLog(@"error:%@",error);
                if (failureBlock) {
                    failureBlock(error);
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO ;
            }
        });
    }];
    // 把当前任务存储到多任务中
    if (_isMoreDataTask == YES) {
        [_dataTasks addObject:_dataTask];
    }
    
    // 05 开始执行任务
    [_dataTask resume];
    
}


// 获取当前对象已经设置内容的数据名字和对应的内容
- (NSMutableDictionary *)getMyClassAttributeNameAndValue
{
    // 1.创建一个可变字典获取当前类的属性和内容
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    // 2.获取当前类中所有属性名字的集合
    // 01 获取当前类
    Class myClass = [self class];
    // 02 获取当前类中属性名字的集合
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(myClass, &count);
    // 03 遍历所有的属性
    for (int i = 0; i < count; i++) {
        // 获取当前属性的名字
        objc_property_t property = properties[i];
        const char * char_property_name = property_getName(property);
        // 如果获取到这个属性的名字
        if (char_property_name) {
            // 转换成字符串对象
            NSString *property_name = [[NSString alloc] initWithCString:char_property_name encoding:NSUTF8StringEncoding];
            // 如果是id的参数我们给他一个明明规范_id
            if ([property_name hasPrefix:@"_"]) {
                property_name = [property_name substringFromIndex:1];
            }
            // 获取当前属性对应的内容
            id value = [self valueForKey:property_name];
            if ([value isKindOfClass:[NSData class]] || (value != nil && [value intValue] != -100)) {
                [attributes setObject:value forKey:property_name];
            }
        }
    }
    
    return attributes;
}

#pragma mark - 把参数转换成二进制数据对象
- (NSData *)getDataStringWithParams:(NSDictionary *)params
{
    // 01 遍历字典把字典里面的参数转换成字符串
    // 创建一个可变字符串
    NSMutableString *paramString = [[NSMutableString alloc] init];
    for (NSString *key in params) {
        [paramString appendFormat:@"&%@=%@",key,params[key]];
    }
    
    if (paramString.length == 0) {
        return nil;
    } else {
        return [[paramString substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
    }
}

@end
