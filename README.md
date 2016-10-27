# UdeskSDK-iOS
Udesk为了让开发者更好的集成移动SDK,与企业业务结合更加紧密，我们开源了SDK的UI界面。用户可以根据自身业务以及APP不同风格重写页面。当然开发者也可以直接用我们提供的默认的界面。

### 注意：

##### 1. 为了保证您的app能正常使用sdk，请使用或及时更新最新版本的sdk

##### 2. v3.3之前的版本未适配iOS10，如需适配iOS10请更新最新的sdk

#### 更新记录：

sdk v3.3.3版本更新功能：

1.支持主动满意度调查

2.push接口增加完成回调

3.文字过多时计算bug修复

4.支持https


## 一、SDK工作流程


Udesk-SDK的工作流程如下图所示。

![udesk](http://7xr0de.com2.z0.glb.qiniucdn.com/ios-new-1.png)

## 二、导入SDK依赖的框架

#### 2.1文件介绍

| Demo中的文件      | 说明                |
| ------------- | ----------------- |
| UDChatMessage | Udesk提供的开源聊天界面    |
| SDK           | Udesk SDK的静态库和头文件 |

|    SDK中的文件     |                    说明                    |
| :------------: | :--------------------------------------: |
| UdeskMessage.h |                  实体类：消息                  |
| UdeskManager.h | Udesk SDK 提供的逻辑 API，开发者可调用其中的逻辑接口，实现自定义在线客服界面 |
|   libUdesk.a   |       Udesk SDK 提供的静态库，实现了SDK底层逻辑        |

#### 2.2引入依赖库

Udesk SDK 的实现，依赖了一些系统框架，在开发应用时，需要在工程里加入这些框架。开发者首先点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -> *BuiLd Phases* -> *Link Binary With Libraries*，展开 *LinkBinary With Libraries* 后点击展开后下面的 *+* 来添加下面的依赖项:

```
libz.tbd
libxml2.tbd
libresolv.tbd
libsqlite3.tbd
```

#### 2.3添加SDK到你的工程

把下载的文件夹中的UdeskSDK文件夹拖到你的工程里，并进行以下配置

- 点击的你工程targets->Build Settings 
- 搜索Other Linker Flags 加入 -lxml2 -ObjC
- 搜索header search paths 加入/usr/include/libxml2

#### 2.4权限问题

如果你使用的是xcode8 请在你项目的Info.plist文件里添加使用相册、相机、麦克风的权限

#### 2.5CocoaPods 导入

在 Podfile 中加入：

```
pod 'UdeskSDK'
```
在 控制器 中引入：
```
#import "Udesk.h"
```

## 三、快速集成SDK

Udesk提供了一套开源的聊天界面，帮助开发者快速创建对话窗口和帮助中心，并提供自定义接口，以实现定制需求。

#### 3.1初始化Udesk  SDK

获取密钥和公司域名。

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/key.jpeg)
```
//初始化Udesk
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.
[UdeskManager initWithAppkey:@"公司密钥" domianName:@"公司域名"];
return YES;
}
```
#### 3.2初始化客户信息

用户系统字段是Udesk已定义好的字段，开发者可以传入这些用户信息，供客服查看。

```
NSDictionary *parameters = @{
@"user": @{
@"nick_name": @"小明",
@"cellphone":@"18888888888",
@"email":@"xiaoming@qq.com",
@"description":@"用户描述",
@"sdk_token":@"xxxxxxxxxxx"
}
}
[UdeskManager createCustomerWithCustomerInfo:parameters];
```

#### 3.3推出聊天页面

```objective-c
//使用push
UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[chat pushUdeskViewControllerWithType:UdeskIM viewController:self];

//使用present
[chat presentUdeskViewControllerWithType:UdeskIM viewController:self];
```

#### 3.5推出机器人页面

确保管理员后后【管理中心-即时通讯-IM机器人】开启机器人SDK IM渠道。可以设置是否允许转人员。使用此界面，则会根据后台配置显示机器人或人工客服对话界面

```objective-c
//使用push
UdeskSDKManager *robot = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[robot pushUdeskViewControllerWithType:UdeskRobot viewController:self];

//使用present
[robot presentUdeskViewControllerWithType:UdeskRobot viewController:self];
```
#### 3.4推出帮助中心

```objective-c
//使用push
UdeskSDKManager *faq = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[faq pushUdeskViewControllerWithType:UdeskFAQ viewController:self];

//使用present
[faq presentUdeskViewControllerWithType:UdeskFAQ viewController:self];
```

#### 3.5推出客服导航

```objective-c
//使用push
UdeskSDKManager *agentMenu = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[agentMenu pushUdeskViewControllerWithType:UdeskMenu viewController:self];

//使用present
[agentMenu presentUdeskViewControllerWithType:UdeskMenu viewController:self];
```



## 四、Udesk SDK 自定义配置

#### 4.1使用SDK提供的UI

##### 原生

    UdeskSDKManager *manager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
    [manager pushUdeskViewControllerWithType:UdeskIM viewController:self];
##### 经典


    UdeskSDKManager *manager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle blueStyle]];
    [manager pushUdeskViewControllerWithType:UdeskIM viewController:self];

#### 4.2自定义UI

    //此处只是示例，更多UI参数请参看 UdeskSDKStyle.h
    UdeskSDKStyle *sdkStyle = [UdeskSDKStyle customStyle];
    sdkStyle.navigationColor = [UIColor yellowColor];
    sdkStyle.titleColor = [UIColor orangeColor];
    
    UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:sdkStyle];
    [chat pushUdeskViewControllerWithType:UdeskIM viewController:self];

#### 4.3指定客服ID

    UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
    [chat setScheduledAgentId:agentId];
    [chat pushUdeskViewControllerWithType:UdeskIM viewController:self];
#### 4.4指定客服组ID

```
UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[chat setScheduledGroupId:groupId];
[chat pushUdeskViewControllerWithType:UdeskIM viewController:self];
```

#### 4.5设置用户头像

    UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
    //通过URL设置头像
    [chat setCustomerAvatarWithURL:@"头像URL"];
    //通过本地图片设置头像
    [chat setCustomerAvatarWithImage:[UIImage imageNamed:@"customer"]];
    [chat pushUdeskViewControllerWithType:UdeskIM viewController:self];
#### 4.6设置SDK语言

```
#import "UdeskLanguageTool.h"
//SDK提供两种语言，中文(CNS) 、英文 (EN) ，默认中文
[[UdeskLanguageTool sharedInstance] setNewLanguage:EN]
```

## 五、Udesk SDK API说明

注意：以下接口在Udesk开源UI里均有调用，如果你使用Udesk的开源UI则不需要调用以下任何接口

#### 5.1初始化SDK

```
//初始化Udesk
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.    
[UdeskManager initWithAppkey:@"公司密钥" domianName:@"公司域名"];   
return YES;
}
```

#### 5.2初始化客户信息

注意：若要在SDK中使用 用户自定义字段 需先在管理员网页端设置添加用户自定义字字段。 用户字段包含了一名客户的所用数据。目前Udesk支持自定义客户字段，您可以选择输入型字段、选择型字段或其他类型字段。

用户系统字段是Udesk已定义好的字段，开发者可以传入这些用户信息，供客服查看。

```
NSDictionary *parameters = @{
@"user": @{
@"nick_name": @"小明",
@"cellphone":@"18888888888",
@"email":@"xiaoming@qq.com",
@"description":@"用户描述",
@"sdk_token":@"xxxxxxxxxxx"
}
}
[UdeskManager createCustomerWithCustomerInfo:parameters];
```

默认客户字段说明

| key           | 是否必选   | 说明         |
| ------------- | ------ | ---------- |
| **sdk_token** | **必选** | **用户唯一标识** |
| cellphone     | 可选     | 用户手机号      |
| email         | 可选     | 邮箱账号       |
| description   | 可选     | 用户描述       |
| nick_name     | 可选     | 用户名字       |

##### 5.2.1添加客户自定义字段

客户自定义字段需要管理员登录Udesk后台进入【管理中心-用户字段】添加用户自定义字段。![udesk](http://7xr0de.com1.z0.glb.clouddn.com/custom.jpeg)

调用用户自定义字段函数

```
//获取用户自定义字段
[UdeskManager getCustomerFields:^(id responseObject, NSError *error) {

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
"field_label" = "测试";  
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

使用:添加key值"customer_field" 类型为字典，根据返回的信息field_name的value 作为key，value根据需求定义。把这个键值对添加到customer_field。最后把customer_field添加到用户信息参数的user字典里  示例:

```
NSDictionary *parameters = @{
@"user": @{
@"sdk_token": sdk_token,
@"nick_name":nick_name,
@"email":email,
@"cellphone":cellphone,
@"description":@"用户描述",
@"customer_field":@{
@"TextField_390":@"测试测试",
@"SelectField_455":@[@"1"]
}

}
};
```

**5.2.2创建用户**

此接口为必调用，否则无法使用SDK

```
[UdeskManager createCustomerWithCustomerInfo:parameters];
```

##### 5.2.3更新用户信息

根据需求自定义，不调用不影响主流程

注意：

- 参数跟创建用户信息的结构体大致一样(不需要传sdk_token)  
- 用户自定义字段"customer_field"改为"custom_fields"其他不变
- 请不要使用已经存在的邮箱或者手机号进行更新，否则会更新失败！

```
NSDictionary *updateParameters = @{
@"user" : @{
@"nick_name":@"测试更新10",
@"cellphone":@"323312110198754326231123",
@"weixin_id":@"xiaoming91078543628818",
@"weibo_name":@"xmwb81497810568328",
@"qq":@"888818682843578910",
@"description":@"用户10描述",
@"email":@"889092340491087556233290111@163.com",
@"custom_fields":@{
@"TextField_390":@"测试测试",
@"SelectField_455":@[@"1"]
}
}
};

[UdeskManager updateUserInformation:updateParameters];
```

#### **5.3**添加咨询对象

根据需求自定义，不调用不影响主流程

```objective-c
 UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
 
 NSDictionary *dict = @{                  											                                   @"productImageUrl":@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa							0ec124ef3_1000x750.jpg",
                        @"productTitle":@"测试测试测试测你测试测试测你测试测试测你测试测试测你测试测试测									    你测试测试测你！",
                        @"productDetail":@"¥88888.088888.088888.0",
                        @"productURL":@"http://www.baidu.com"
                        };
 [chat setProductMessage:dict];
 [chat pushUdeskViewControllerWithType:UdeskIM viewController:self];
```

SDK 咨询对象展示:

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/%E5%92%A8%E8%AF%A2%E5%AF%B9%E8%B1%A1.png)



#### 5.4请求分配客服

在获取当前客户的帐号信息后，调用此接口，请求分配客服，获得客服信息和以及排队信息，可参考开源UI

```
[UdeskManager requestRandomAgent:^(UdeskAgent *agent, NSError *error) {  

//返回客服信息
}];
```

#### 5.5指定分配客服 

在获取当前客户的帐号信息后，调用此接口可主动指定分配客服，获得客服信息和以及排队信息，可参考开源UI

```
[UdeskManager scheduledAgentId:agentId completion:^(UdeskAgent *agent, NSError *error) {

}];
```

#### 5.6指定分配客服组

在获取当前客户的帐号信息后，调用此接口可主动指定分配客服组，获得客服信息和以及排队信息，可参考开源UI

```
[UdeskManager scheduledGroupId:groupId completion:^(UdeskAgent *agent, NSError *error) {

}];
```

**获取客服和客服组ID**

使用管理员登陆Udesk系统

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/%E8%8E%B7%E5%8F%96%E5%AE%A2%E6%9C%8Did.jpg)



#### 5.7断开与Udesk服务器连接 

切换用户时，调用此接口断开上一个客户的连接

```
[UdeskManager logoutUdesk];
```

#### 5.8设置客户上线

连接Udesk服务器后客户默认在线，在设置客户离线后，调用此接口可以上客户重新上线。

```
[UdeskManager setCustomerOnline];
```

#### 5.9设置接收消息代理

设置接收消息的代理，由代理来接收消息。

设置代理后，实现 `UDManagerDelegate` 中的 `didReceiveMessages:` `didReceivePresence:` `didReceiveSurvey:withAgentId:` 方法，即可通过这些代理函数接收消息。

```
[UdeskManager receiveUdeskDelegate:self]; 
```

#### 5.10发送消息

调用此接口开发送各种类型的消息，注意选择正确的消息类型。

//message消息类型为 UdeskMessage
[UdeskManager sendMessage:message completion:^(UdeskMessage *message,BOOL sendStatus) {    

}];
#### 5.11输入预知

将用户正在输入的内容，实时显示在客服对话窗口。该接口没有调用限制，但每1秒内只会向服务器发送一次数据）

注意：需要在初始化成功后，且客服是在线状态时调用才有效

```
[UdeskManager sendClientInputtingWithContent:text];
```

#### 5.12获取客户本地聊天数据

```
[UdeskManager getHistoryMessagesFromDatabaseWithMessageDate:[NSDate date] messagesNumber:20 result:^(NSArray *messagesArray) {
        
}];
```

#### 5.13监听收到未读消息的广播

开发者可在合适的地方，监听收到消息的广播，用于提醒顾客有新消息。广播的名字为 `UD_RECEIVED_NEW_MESSAGES_NOTIFICATION`，定义在 UdeskManager.h 中。

#### 5.14获取未读消息数量

开发者可以在需要显示未读消息数是调用此接口，当用户进入聊天界面后，未读消息将会清零。

```
[UdeskManager getLocalUnreadeMessagesCount];
```

#### 4.15获取未读消息

开发者可以在需要显示未读消息时调用此接口，当用户进入聊天界面后，未读消息将会清空。

```
[UdeskManager getLocalUnreadeMessages];
```

#### 4.16获取机器人URL

当前SDK的机器人是web网页来实现，通过此接口可以获取机器人网页的URL，在webview里打开后即可以与机器人对话。

```
[UdeskManager getRobotURL:^(NSURL *robotUrl) {
}];
```

