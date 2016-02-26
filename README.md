# UdeskSDK-iOS
UdeskSDK-iOS

## iOS新版说明

> Udesk为了让开发者更好的集成移动SDK,与企业业务结合更加紧密，我们开源了SDK的UI界面。用户可以根据自身业务以及APP不同风格重写页面。当然开发者也可以直接用我们提供的默认的界面。


## 1、SDK工作流程


Udesk-SDK的工作流程如下图所示。

![udesk](http://7xr0de.com2.z0.glb.qiniucdn.com/ios-new-1.png)


## 2、导入SDK依赖的框架
```
libz.tbd
libxml2.tbd
libresolv.tbd
libsqlite3.tbd
JavaScriptCore.framework
```

把SDK文件夹中的Udesk文件夹拖到你的工程里
点击的你工程targets->Build Settings 搜索Other Linker Flags 加入 –lxml2 -ObjC

.pch 引入 UDTools.h

文件介绍

|Demo中的文件 |说明 |
|--------|:------|
|UDChatMessage |Udesk提供的开源聊天界面 | 
|SDK|Udesk SDK的静态库和头文件|
|Resource|Udesk资源文件|

## 4、快速集成SDK

### 1）、初始化Udesk，获取密钥和公司域名。
![udesk](http://7xr0de.com2.z0.glb.qiniucdn.com/ios3.png)
```
//初始化Udesk
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.
[UDManager initWithAppkey:@"公司密钥" domianName:@"公司域名"];
return YES;
}
```
### 2）、初始化用户信息
> 注意：若要在SDK中使用 用户自定义字段 需先在网页端设置添加用户自定义字字段。 用户字段包含了一名联系人的所用数据。目前Udesk完全支持自定义用户字段，您可以选择输入型字段和选择型字段。如果是选择型字段，需要提供多个自定义的选项供您的客户进行选择。如果是输入型字段，用户会看到一个文本输入框，在其中输入数据。

用户系统字段是Udesk已定义好的字段，开发者可以传入这些用户信息，供客服查看。
```
NSDictionary *parameters = @{
@"user": @{

@"nick_name": @"小明",
@"cellphone":@"18888888888",
@"weixin_id":@"xiaoming888",
@"weibo_name":@"xmwb888",
@"qq":@"8888888",
@"email":@"xiaoming@qq.com",
@"description":@"用户描述",
@"sdk_token":@"xxxxxxxxxxx"
}
}

```

字段说明：

|key |是否必选 |说明 |
|--------|:------|------|
|sdk_token|必选|用户唯一标识|
|cellphone |可选|用户手机号|
|weixin_id |可选|微信号|
|weibo_name |可选|微博ID|
|qq|可选|QQ号|
|email|可选|邮箱账号|
|description|可选|用户描述|


用户自定义字段：
用户自定义字段需要登录Udesk后台，进入“管理中心-用户字段”添加用户自定义字段。
![udesk](http://7xr0de.com2.z0.glb.qiniucdn.com/ios4.png)

调用用户自定义字段函数：
```
//获取用户自定义字段
[UDManager getCustomerFields:^(id responseObject, NSError *error) {

//NSLog(@"用户自定义字段：%@",responseObject);
}];
```

返回信息：
```
fieldsDict:{
message = success;
status = 0;
"user_fields" =     (
{
comment = “测试测试”;      
"content_type" = droplist; 
"field_label" = "测试";   ———————————-用户自定义字段value
"field_name" = “SelectField_109";   ——————用户自定义字段key
options =             (    
{
0 = "测试用户自定义字段";
}
);
permission = 0;
requirment = 1;
};
}
```
> 注意：field_name的value为用户自定义字段key field_label的value为用户自定义字段value
把这个键值对添加到@“user”字典，客服就能看到用户自定义字段了

创建用户
```
[UDManager createCustomer:parameters completion:^(NSString *customerId, NSError *error) {

NSLog(@"用户ID:%@",customerId);
//提交用户设备信息
[UDManager submitCustomerDevicesInfo:^(id responseObject, NSError *error) {

NSLog(@"提交设备信息:%@",responseObject);
}];

//获取用户登录信息
[UDManager getCustomerLoginInfo:^(NSDictionary *loginInfoDic, NSError *error) {

NSLog(@"用户登录信息:%@",loginInfoDic);
}];

}];

```

用户点击事件里需要引入.h文件

### 3）、推出聊天页面
```
UDChatViewController *chat = [[UDChatViewController alloc] init];

[self.navigationController pushViewController:chat animated:YES];

```

### 4）、推出帮助中心
```
UDFaqController *faq = [[UDFaqController alloc] init];

[self.navigationController pushViewController:faq animated:YES];

```

### 5）、推出机器人页面
```
UDRobotIMViewController *robot = [[UDRobotIMViewController alloc] init];

[self.navigationController pushViewController:robot animated:YES];

```
至此，你已经为你的 APP 添加Udesk提供的客服服务。而Udesk SDK 还提供其他强大的功能，可以帮助提高服务效率，提升用户使用体验。接下来为你详细介绍如何使用其他功能

## 5、接口说明

```
/**
*  初始化Udesk
*
*  @param key    公司密钥
*  @param domain 公司域名
*/
+ (void)initWithAppkey:(NSString *)key domianName:(NSString *)domain;
/**
*  创建用户
*
*  @param customerMsg 用户信息
*  @param completion  创建成功回调（返回用户ID）
*/
+ (void)createCustomer:(NSDictionary *)customerMsg
completion:(void (^)(NSString *customerId,NSError *error))completion;

/**
*  获取用户的登录信息
*
*  @param completion 回调用户登录信息
*/
+ (void)getCustomerLoginInfo:(void (^)(NSDictionary *loginInfoDic,NSError *error))completion;

/**
*  通过开发者存储的用户ID获取用户登录信息
*
*  @param customerId 用户ID
*  @param completion 回调用户信息
*/
+ (void)getCustomerLoginInfo:(NSString *)customerId
completion:(void (^)(NSDictionary *loginInfoDic,NSError *error))completion;

/**
*  获取客服信息
*
*  @param completion 回调客服信息
*/
+ (void)getAgentInformation:(void (^)(id responseObject,NSError *error))completion;

/**
*  通过开发者存储的用户ID获取客服信息
*
*  @param customerId 用户ID
*  @param completion 回调客服信息
*/
+ (void)getAgentInformation:(NSString *)customerId
completion:(void (^)(id responseObject,NSError *error))completion;

/**
*  登录Udesk
*
*  @param userName        用户帐号
*  @param password        用户密码
*  @param completion      回调登录状态
*  @param receiveDelegate 接收消息和接收状态代理
*/
+ (void)loginUdeskWithUserName:(NSString *)userName
password:(NSString *)password
completion:(void (^) (BOOL status))completion
receiveDelegate:(id<UDManagerDelegate>)receiveDelegate;

/**
*  登录Udesk
*
*  @param completion      回调登录状态
*  @param receiveDelegate 接收消息和接收状态代理
*/
+ (void)loginUdesk:(void (^) (BOOL status))completion
receiveDelegate:(id<UDManagerDelegate>)receiveDelegate;

/**
*  退出Udesk
*/
+ (void)logoutUdesk;

/**
*  发送消息
*
*  @param message    UDMessage类型消息体
*  @param completion 发送回调
*/
+ (void)sendMessage:(UDMessage *)message
completion:(void (^) (UDMessage *message,BOOL sendStatus))completion;

/**
*  获取用户自定义字段
*
*  @param completion 回调用户自定义子段信息
*/
+ (void)getCustomerFields:(void (^)(id responseObject, NSError *error))completion;
/**
*  提交用户设备信息
*
*  @param completion 回调提交状态
*/
+ (void)submitCustomerDevicesInfo:(void (^)(id responseObject, NSError *error))completion;

/**
*  通过开发者存储的用户ID提交用户设备信息
*
*  @param customerId 用户ID
*  @param completion 回调提交状态
*/
+ (void)submitCustomerDevicesInfo:(NSString *)customerId
completion:(void (^)(id responseObject, NSError *error))completion;

/**
*  获取公司帮助中心文章
*
*  @param completion 回调帮助中心文章信息
*/
+ (void)getFaqArticles:(void (^)(id responseObject, NSError *error))completion;

/**
*  获取公司帮助中心文章内容
*
*  @param contentId  文章内容ID
*  @param completion 回调文章内容信息
*/
+ (void)getFaqArticlesContent:(NSString *)contentId
completion:(void (^)(id responseObject, NSError *error))completion;

/**
*  搜索帮助中心文章
*
*  @param content    搜索内容
*  @param completion 回调搜索信息
*/
+ (void)searchFaqArticles:(NSString *)content
completion:(void (^)(id responseObject, NSError *error))completion;

/**
*  获取提交工单URL
*
*  @return 提交工单URL
*/
+ (NSURL *)getSubmitTicketURL;

/**
*  获取机器人URL
*
*  @return 机器人URL
*/
+ (NSURL *)getRobotURL;

/**
*  异步获取
*
*  @param completion 回调机器人URL
*/
+ (void)getRobotURL:(void(^)(NSURL *robotUrl))completion;

/**
*  插入信息到数据库
*
*  @param sql    sql语句
*  @param params 参数
*
*  @return 插入状态
*/
+ (BOOL)insertTableWithSqlString:(NSString *)sql params:(NSArray *)params;

/**
*  查询数据库
*
*  @param sql           sql语句
*  @param params        参数
*  @param finishedblock 回调查询内容
*/
+ (void)queryTabelWithSqlString:(NSString *)sql
params:(NSArray *)params
finishedBlock:(void (^) (NSArray *dbData))finishedblock;


/**
*  删除数据库内容
*
*  @param sql    sql语句
*  @param params 参数
*
*  @return 删除状态
*/
+ (BOOL)deleteTableWithSqlString:(NSString *)sql params:(NSArray *)params;

/**
*  修改数据库内容
*
*  @param sql    sql语句
*  @param params 参数
*
*  @return 修改状态
*/
+ (BOOL)updateTableWithSqlString:(NSString *)sql params:(NSArray *)params;

/**
*  获取客服注册的Udesk域名
*
*  @return 域名
*/
+ (NSString *)domain;
/**
*  获取用户Udesk key
*
*  @return Udesk key
*/
+ (NSString *)key;
/**
*  机器人客服是否支持转移
*
*  @return 是否支持转移
*/
+ (BOOL)supportTransfer;

/**
*  设置客户离线 (在用户点击home键后调用此方法)
*/
+ (void)setCustomerOffline;

/**
*  设置客户在线 (在用户将要进入app的时候调用此方法)
*/
+ (void)setCustomerOnline;

```
