//
//  SMDataService.h
//  SMDataService
//
//  Created by 朱思明 on 15/11/17.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//


/*
    此方法的优点:
    1.可以使用面向对象形式进行网络请求，一个接口地址可以想象成一个对象。
    2.此类是一个虚类，尽量子类化使用。网络请求的参数定义成子类的属性，此类通过使用runtime机制自动读取属性的名字和内容拼接成网络请求参数自动上传，如参数不设置内容，责此参数不会上传。
    3.在简单的网络请求中，可能此类不会占有优势，如果在复杂的数据也不处理中，可以使用此类的子类进行复写网络请求的block方法，在这里面进行数据业务处理，返回处理后的数据。
    4.通过此类我们设计架构的时候就可以引入service层来做数据请求和数据处理，从而来增加MVC架构模式的可读性
    5.此类使用NSUrlSession可以是用allowsCellularAccess属性
    6.是否允许多任务，就是同一个网络请求对象中是否允许在同一时间有多个网络请求存在。如果不允许择前一次的网络请求会被暂停掉
    7.当次对象释放的时候，会取消网络请求
    8.如果请求参数是关键字，定义属性的名字在前面添加(_) 例如：id 定义成 _id
     
    iOS9引入了新特性App Transport Security (ATS)。
    新特性要求App内访问的网络必须使用HTTPS协议。
    但是现在很多项目使用的是HTTP协议，现在也不能马上改成HTTPS协议传输。
    那么如何设置才能在iOS9中使用Http请求呢
    解决办法：
    在Info.plist中add Row添加NSAppTransportSecurity类型Dictionary。
    在NSAppTransportSecurity下添加NSAllowsArbitraryLoads类型Boolean,值设为YES
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 超时时间
static const NSInteger DEFAULT_TIMEOUT = 30;

// 定义block类型
typedef void(^FinishBlock)(id result);          // 请求成功
typedef void(^FailureBlock)(NSError *error);    // 请求失败
typedef void(^SetParamsBlock)(void);            // 设置参数d的block

@interface SMDataService : NSObject
{
    NSMutableArray *_dataTasks; // 任务存储数组
}
// 如果是id的参数我们给他一个规范_id
// 网络请求参数配置
@property (nonatomic, strong) NSString *api_url;
// 网络请求类型（GET/PUT/DELETE/POST） 注意：此类中设置的PUT和DELETE请求方式和GET一致
@property (nonatomic, strong) NSString *httpMethod;
// 配置是否允许使用蜂窝数据(默认是允许的)
@property (nonatomic, assign) BOOL allowsCellularAccess;
// 是否允许多任务
@property (nonatomic, assign) BOOL isMoreDataTask;
// 网络请求对象
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

#pragma mark - 开始网络请求
- (void)requestDataWithParamsBlcok:(SetParamsBlock)paramsBlock
                       finishBlock:(FinishBlock)finishBlock
                      failureBlock:(FailureBlock)failureBlock;

@end
