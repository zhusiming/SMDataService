#SMDataService

这是一个面向对象网络请求框架，可以在iOS项目开发中增加数据处理层，从而让你的架构更加的清晰。 This is an object-oriented network request framework, you can increase the data processing layer in the iOS project development, so as to make your architecture more clear.



#Benefits of classes

    1.可以使用面向对象形式进行网络请求，一个接口地址可以想象成一个对象。
    2.此类是一个虚类，尽量子类化使用。网络请求的参数定义成子类的属性，此类通过使用runtime机制自动读取属性的名字和内容拼接成网络请求参数自动上传，如参数不设置内容，责此参数不会上传。
    3.在简单的网络请求中，可能此类不会占有优势，如果在复杂的数据也不处理中，可以使用此类的子类进行复写网络请求的block方法，在这里面进行数据业务处理，返回处理后的数据。
    4.通过此类我们设计架构的时候就可以引入service层来做数据请求和数据处理，从而来增加MVC架构模式的可读性
    5.此类使用NSUrlSession可以是用allowsCellularAccess属性
    6.是否允许多任务，就是同一个网络请求对象中是否允许在同一时间有多个网络请求存在。如果不允许择前一次的网络请求会被暂停掉
    7.当次对象释放的时候，会取消网络请求
    8.如果请求参数是关键字，定义属性的名字在前面添加(_) 例如：id 定义成 _id



#Architecture

####SMDataService

####SMBaseModel



#Usage

####SMDataService

必须子类化SMDataService对象方可使用

####Creating a Data Task

子类化SMDataService对象（NewsDataService），设置参数（也就是定义子类的属性），如果请求参数是关键字，定义属性的名字在前面添加(_) 例如：id 定义成 _id

    @property (nonatomic, assign) int type;    // 请求数据的类型 1：为新闻

重新定义网络请求方法，添加数据处理业务 

NewsDataService.h代码

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

NewsDataService.m代码

    #import "NewsDataService.h"
    
    @implementation NewsDataService
    
    /*
     *  初始化定义参数
     */
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

开始网络请求使用代码

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

####SMBaseModel

是为了方便数据原型创建的基类，如参数名字和子类属性的名字相同可以实现自动映射功能

如果参数类型或者名字不能直接映射可以集成父类初始化方法，手动添加映射

####Creating a Model

例如子类化SMBaseModel（NewModel类）,赋值代码如下：

    NewModel * newModel = [[NewModel alloc] initWithContentDic:dic];

如不能完成的数据原型中部分数据的映射，可以在NewModel.m中实现下面代码：

    /*
     
    - (instancetype)initWithContentDic:(NSDictionary *)dic
    {
        // 通过调用父累的方法把能映射到属性中的数据进行赋值
        self = [super initWithContentDic:dic];
        if (self) {
            // 不能映射的数据手动复制,例如
            self.newId = dic[@"id"];
        }
        return self;
    }
     */



#Experience

如果完全的学习和理解此类的设计理念和使用方法：

1、可以让你学习到runtime的基本方法使用和映射数据理念

2、如果你理解并使用MVC架构设计模式，加入此类的使用。那么它不光能解决你网络请求的问题，最主要他能够解决你控制器部分数据业务处理带来的压力。使用这个类更想让你在架构设计模式中加入service数据处理层的考虑。

如有建议和问题可发送邮箱：siming_zhu@163.com
