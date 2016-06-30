//
//  NewModel.h
//  SMDataService
//
//  Created by 朱思明 on 15/11/17.
//  Copyright © 2015年 github 网址：https://github.com/zhusiming All rights reserved.
//

#import "SMBaseModel.h"

@interface NewModel : SMBaseModel
/** 长标题 */
@property (nonatomic, copy) NSString * longTitle;

/** 短标题 */
@property (nonatomic, copy) NSString * shortTitle;

/** 信息 */
@property (nonatomic, copy) NSString * info;

/** 备注 */
@property (nonatomic, copy) NSString * remark;

/** 关键字 */
@property (nonatomic, copy) NSString * keyWord;

/** 图片地址 */
@property (nonatomic, copy) NSString * imageUrl;

/** 创建时间 */
@property (nonatomic, copy) NSString * createDateString;

/** 开始时间 */
@property (nonatomic, copy) NSString * beginDateString;

/** 结束时间 */
@property (nonatomic, copy) NSString * endDateString;

/** 点击次数 */
@property (nonatomic, copy) NSString * click;

/** 作者 */
@property (nonatomic, copy) NSString * writer;

/** 来源 */
@property (nonatomic, copy) NSString * source;

/** 唯一标示 */
@property (nonatomic, copy) NSString * pid;
@end
