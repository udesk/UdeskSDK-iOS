# UdeskSDK-iOS
Udesk为了让开发者更好的集成移动SDK,与企业业务结合更加紧密，我们开源了SDK的UI界面。用户可以根据自身业务以及APP不同风格重写页面。当然开发者也可以直接用我们提供的默认的界面。

## 目录
- [一、SDK工作流程](#%E4%B8%80sdk%E5%B7%A5%E4%BD%9C%E6%B5%81%E7%A8%8B)
- [二、导入SDK依赖的框架](#%E4%BA%8C%E5%AF%BC%E5%85%A5sdk%E4%BE%9D%E8%B5%96%E7%9A%84%E6%A1%86%E6%9E%B6)
- [三、快速集成SDK](#%E4%B8%89%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90sdk)
- [四、Udesk SDK 自定义配置](#%E5%9B%9Budesk-sdk-%E8%87%AA%E5%AE%9A%E4%B9%89%E9%85%8D%E7%BD%AE)
- [五、消息推送](#%E4%BA%94%E6%B6%88%E6%81%AF%E6%8E%A8%E9%80%81)
- [六、Udesk SDK API说明](#%E5%85%ADudesk-sdk-api%E8%AF%B4%E6%98%8E)
- [七、常见问题](#%E4%B8%83%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)
- [八、更新记录](#%E5%85%AB%E6%9B%B4%E6%96%B0%E8%AE%B0%E5%BD%95)



# 一、SDK工作流程


Udesk-SDK的工作流程如下图所示。

![udesk](http://7xr0de.com2.z0.glb.qiniucdn.com/ios-new-1.png)

# 二、导入SDK依赖的框架

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

```objective-c
pod 'UdeskSDK'
```
在 控制器 中引入：
```objective-c
#import "Udesk.h"
```

# 三、快速集成SDK

Udesk提供了一套开源的聊天界面，帮助开发者快速创建对话窗口和帮助中心，并提供自定义接口，以实现定制需求。

#### 3.1初始化Udesk  SDK

获取appkey和appId。

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/initUdesk.png)

##### 注意：appKey、appID、domain都是必传字段

```objective-c
//初始化Udesk
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
    [UdeskManager initWithAppKey:@"App Key" appId:@"App ID" domain:@"公司注册的Udesk域名"];
	return YES;
}
```
#### 3.2初始化客户信息

用户系统字段是Udesk已定义好的字段，开发者可以传入这些用户信息，供客服查看。

```objective-c
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
[chat pushUdeskInViewController:self completion:nil];

//使用present
[chat presentUdeskInViewController:self completion:nil];
```

#### 3.4推出帮助中心

```objective-c
//使用push
UdeskSDKManager *faq = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[faq pushUdeskInViewController:self udeskType:UdeskFAQ completion:nil];

//使用present
[faq presentUdeskInViewController:self udeskType:UdeskFAQ completion:nil];
```

# 四、Udesk SDK 自定义配置

#### 4.1使用SDK提供的UI

##### 原生

```objective-c
UdeskSDKManager *manager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[manager pushUdeskInViewController:self completion:nil];
```
##### 经典


```objective-c
UdeskSDKManager *manager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle blueStyle]];
[manager presentUdeskInViewController:self completion:nil];
```

#### 4.2自定义UI

```objective-c
//此处只是示例，更多UI参数请参看 UdeskSDKStyle.h
UdeskSDKStyle *sdkStyle = [UdeskSDKStyle customStyle];
sdkStyle.navigationColor = [UIColor yellowColor];
sdkStyle.titleColor = [UIColor orangeColor];

UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:sdkStyle];
[chat pushUdeskInViewController:self completion:nil];
```

#### 4.3指定客服ID

```objective-c
UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[chat setScheduledAgentId:agentId];
[chat pushUdeskInViewController:self udeskType:UdeskIM completion:nil];
```
#### 4.4指定客服组ID

```objective-c
UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[chat setScheduledGroupId:groupId];
[chat pushUdeskInViewController:self udeskType:UdeskIM completion:nil];
```

#### 4.5设置用户头像

```objective-c
UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
//通过URL设置头像
[chat setCustomerAvatarWithURL:@"头像URL"];
//通过本地图片设置头像
[chat setCustomerAvatarWithImage:[UIImage imageNamed:@"customer"]];
[chat pushUdeskInViewController:self completion:nil];
```
#### 4.6设置SDK语言

```objective-c
#import "UdeskLanguageTool.h"
//SDK提供两种语言，中文(CNS) 、英文 (EN) ，默认中文
[[UdeskLanguageTool sharedInstance] setNewLanguage:EN]
```

#### 4.7设置放弃排队类型

```objective-c
UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
//如果用户处于排队状态，当用户离开聊天界面，会强制把该用户移除排队
//默认为标记排队（指不会放弃排队）
[chatViewManager setQuitQueueType:UdeskForceQuit];
[chatViewManager pushUdeskInViewController:self completion:nil];
```

#### 4.8自定义留言界面

```objective-c
UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
//点击留言回调
[chatViewManager leaveMessageButtonAction:^(UIViewController *viewController){
  
    UdeskTicketViewController *offLineTicket = [[UdeskTicketViewController alloc] init];
    [viewController presentViewController:offLineTicket animated:YES completion:nil];
}];
```

#### 注意：如果你自定义的留言界面是h5的，恰好你们有上传附件的功能，这时候你们需要添加以下代码到你们自定义的控制器，否则选择附件的时候会直接返回到上一页

1.使用presentViewController 进入到留言页

2.重写dismissViewControllerAnimated方法

```objective-c
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ( self.presentedViewController)
    {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}
```

3.在需要dismiss的时候调用：

```objective-c
[super dismissViewControllerAnimated:flag completion:completion];
```

# 五、消息推送

当前仅支持一种推送方案，即Udesk服务端发送消息至开发者的服务端，开发者再推送消息到 App。

未来Udesk iOS SDK 将会支持直接推送消息给 App，即开发者可上传 App 的推送证书至Udesk，Udesk将推送消息至苹果 APNS 服务器。

### 设置接收推送的服务器地址

推送消息将会发送至开发者的服务器。

设置推送服务器地址，请使用Udesk管理员帐号登录 Udesk，在「设置」 -> 「移动SDK」中设置。

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/5D761252-3D9D-467C-93C9-8189D0B22424.png)



### 上传设备的 deviceToken

App 进入后台后，Udesk推送给开发者服务端的消息数据格式中，会有 deviceToken 的字段。

将下列代码添加到 `AppDelegate.m` 中系统回调 `didRegisterForRemoteNotificationsWithDeviceToken`中：

```
[UdeskManager registerDeviceToken:deviceToken];
```

### 通知Udesk服务端发送消息至开发者的服务端

目前，Udesk的推送是通过推送消息给开发者提供的 URL 上来实现的。

在 App 进入后台时，应该通知Udesk服务端，让其将以后的消息推送给开发者提供的服务器地址。

开发者需要在 `AppDelegate.m` 的系统回调 `applicationDidEnterBackground` 调用开启推送服务接口，如下代码：

```objective-c
- (void)applicationDidEnterBackground:(UIApplication *)application {

  __block UIBackgroundTaskIdentifier background_task;
  //注册一个后台任务，告诉系统我们需要向系统借一些事件
  background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
  
//不管有没有完成，结束background_task任务
  [application endBackgroundTask: background_task];
  background_task = UIBackgroundTaskInvalid;
    }];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      //根据需求 开启／关闭 通知
      [UdeskManager startUdeskPush];
  });
}
```
### 关闭Udesk推送

在 App 进入前台时，应该通知Udesk服务端，让其将以后的消息发送给SDK，而不再推送给开发者提供的服务端。

开发者需要在 `AppDelegate.m` 的系统回调 `applicationWillEnterForeground` 调用关闭推送并拉取消息接口，如下代码：

```objective-c
- (void)applicationWillEnterForeground:(UIApplication *)application {

    //上线操作，拉取离线消息
    [UdeskManager setupCustomerOnline];
}
```

### 离线推送接口要求

**基本要求**

- 推送接口只支持 http，不支持 https
- 数据将以 JSON 格式发送
- 请求 Body 数据为 JSON 格式，见示例
- 请求时使用的 content-type 为 application/x-www-form-urlencoded

**参数**

当有消息或事件发生时，将会向推送接口传送以下数据

| 参数名          | 类型       | 说明                                       |
| ------------ | -------- | ---------------------------------------- |
| message_id   | string   | 消息id                                     |
| platform     | string   | 平台，'ios' 或 'android'                     |
| device_token | string   | 设备标识                                     |
| app_id       | string   | SDK app id                               |
| content      | string   | 消息内容，仅 type 为 'message' 时有效              |
| sent_at      | datetime | 消息推送时间，格式 iso8601                        |
| from_id      | integer  | 发送者id(客服)                                |
| from_name    | string   | 发送者名称                                    |
| to_id        | integer  | 接收者id(客户)                                |
| to_token     | string   | 接收者 sdk_token(唯一标识)                      |
| type         | string   | 消息类型，'event' 为事件，'message'为消息            |
| event        | string   | 事件类型，'redirect' 客服转接，'close'对话关闭，'survey'发送满意度调查 |



**参数示例**

```json
{
    "message_id": "di121jdlasf82jfdasfklj39dfda",
    "platform": "ios",
    "device_token": "4312kjklfds2",
    "app_id": "dafjidalledaf",
    "content": "Hello world!",
    "sent_at": "2016-11-21T10:40:38+08:00",
    "from_id": 231,
    "from_name": "Tom",
    "to_id": 12,
    "to_token": "dae121dccepm1",
    "type": "message",
  	"event": "close"
}
```

#### 注意：如果你不使用推送 

##### 请在app切换到后台调用以下接口

```objective-c
- (void)applicationDidEnterBackground:(UIApplication *)application {
  
  	//设置离线，客服发送离线消息
	[UdeskManager setupCustomerOffline]
}
```

##### 请在在切换到前台调用以下接口

```objective-c
- (void)applicationWillEnterForeground:(UIApplication *)application {

    //上线操作，拉取离线消息
    [UdeskManager setupCustomerOnline];
}
```

# 六、Udesk SDK API说明

注意：以下接口在Udesk开源UI里均有调用，如果你使用Udesk的开源UI则不需要调用以下任何接口

#### 6.1初始化SDK

```objective-c
//初始化Udesk
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.    
[UdeskManager initWithAppKey:@"App Key" appId:@"App ID" domain:@"公司注册的Udesk域名"]; 
return YES;
}
```

#### 6.2初始化客户信息

注意：若要在SDK中使用 用户自定义字段 需先在管理员网页端设置添加用户自定义字字段。 用户字段包含了一名客户的所用数据。目前Udesk支持自定义客户字段，您可以选择输入型字段、选择型字段或其他类型字段。

用户系统字段是Udesk已定义好的字段，开发者可以传入这些用户信息，供客服查看。

```objective-c
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

**注意sdktoken** 是客户的唯一标识，用来识别身份，**sdk_token: 传入的字符请使用 字母 / 数字 等常见字符集** 。就如同身份证一样，不允许出现一个身份证号对应多个人，或者一个人有多个身份证号;**其次**如果给顾客设置了邮箱和手机号码，也要保证不同顾客对应的手机号和邮箱不一样，如出现相同的，则不会创建新顾客。 

##### 6.2.1添加客户自定义字段

客户自定义字段需要管理员登录Udesk后台进入【管理中心-用户字段】添加用户自定义字段。![udesk](http://7xr0de.com1.z0.glb.clouddn.com/custom.jpeg)

调用用户自定义字段函数

```objective-c
//获取用户自定义字段
[UdeskManager getCustomerFields:^(id responseObject, NSError *error) {

//NSLog(@"用户自定义字段：%@",responseObject);
}];
```

返回信息：

```objective-c
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

```objective-c
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

**6.2.2创建用户**

此接口为必调用，否则无法使用SDK

```objective-c
[UdeskManager createCustomerWithCustomerInfo:parameters];
```

##### 6.2.3更新用户信息

根据需求自定义，不调用不影响主流程

注意：

- 参数跟创建用户信息的结构体大致一样(不需要传sdk_token)  
- 用户自定义字段"customer_field"改为"custom_fields"其他不变
- 请不要使用已经存在的邮箱或者手机号进行更新，否则会更新失败！

```objective-c
NSDictionary *updateParameters = @{
@"user" : @{
@"nick_name":@"测试更新10",
@"cellphone":@"323312110198754326231123",
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

#### **6.3**添加咨询对象

根据需求自定义，不调用不影响主流程

| 参数名             | 类型     | 说明      |  必填  |
| --------------- | ------ | ------- | :--: |
| productImageUrl | string | 咨询对象图片  |  是   |
| productTitle    | string | 咨询对象标题  |  是   |
| productDetail   | string | 咨询对象副标题 |  是   |
| productURL      | string | 咨询对象连接  |  是   |

##### 示例

```objective-c
 UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
 
 NSDictionary *dict = @{                  											                                   @"productImageUrl":@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa							0ec124ef3_1000x750.jpg",
                        @"productTitle":@"测试测试测试测你测试测试测你测试测试测你测试测试测你测试测试测									    你测试测试测你！",
                        @"productDetail":@"¥88888.088888.088888.0",
                        @"productURL":@"http://www.baidu.com"
                        };
 [chat setProductMessage:dict];
 [chat pushUdeskInViewController:self completion:nil];
```

SDK 咨询对象展示:

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/%E5%92%A8%E8%AF%A2%E5%AF%B9%E8%B1%A1.png)



#### 6.4请求分配客服

在获取当前客户的帐号信息后，调用此接口，请求分配客服，获得客服信息和以及排队信息，可参考开源UI

```objective-c
[UdeskManager requestRandomAgent:^(UdeskAgent *agent, NSError *error) {  

//返回客服信息
}];
```

#### 6.5指定分配客服 

在获取当前客户的帐号信息后，调用此接口可主动指定分配客服，获得客服信息和以及排队信息，可参考开源UI

```objective-c
[UdeskManager scheduledAgentId:agentId completion:^(UdeskAgent *agent, NSError *error) {

}];
```

#### 6.6指定分配客服组

在获取当前客户的帐号信息后，调用此接口可主动指定分配客服组，获得客服信息和以及排队信息，可参考开源UI

```objective-c
[UdeskManager scheduledGroupId:groupId completion:^(UdeskAgent *agent, NSError *error) {

}];
```

**获取客服和客服组ID**

使用管理员登陆Udesk系统

管理员在【管理中心-即时通讯-网页插件-管理默认网站接入插件-基本信息-专用链接】中选择指定的客服组或客服，可看到客服ID和客服组ID。

#### 6.7断开与Udesk服务器连接 

切换用户时，调用此接口断开上一个客户的连接

```objective-c
[UdeskManager logoutUdesk];
```

#### 6.8设置客户上线

连接Udesk服务器后客户默认在线，在设置客户离线后，调用此接口可以上客户重新上线。

```objective-c
[UdeskManager setupCustomerOnline];
```

#### 6.8设置客户离线

设置客户离线，用户开启推送，开发者可以不必调用。

```objective-c
[UdeskManager setupCustomerOffline];
```

#### 6.9设置接收消息代理

设置接收消息的代理，由代理来接收消息。

设置代理后，实现 `UDManagerDelegate` 中的 `didReceiveMessages:` `didReceivePresence:` `didReceiveSurvey:withAgentId:` 方法，即可通过这些代理函数接收消息。

```objective-c
[UdeskManager receiveUdeskDelegate:self]; 
```

#### 6.10发送消息

调用此接口开发送各种类型的消息，注意选择正确的消息类型。

```objective-c
//message消息类型为 UdeskMessage
[UdeskManager sendMessage:message completion:^(UdeskMessage *message,BOOL sendStatus) {    

}];
```

#### 6.11输入预知

将用户正在输入的内容，实时显示在客服对话窗口。该接口没有调用限制，但每1秒内只会向服务器发送一次数据）

注意：需要在初始化成功后，且客服是在线状态时调用才有效

```objective-c
[UdeskManager sendClientInputtingWithContent:text];
```

#### 6.12获取客户本地聊天数据

```objective-c
[UdeskManager getHistoryMessagesFromDatabaseWithMessageDate:[NSDate date] messagesNumber:20 result:^(NSArray *messagesArray) {
        
}];
```

#### 6.13监听收到未读消息的广播

开发者可在合适的地方，监听收到消息的广播，用于提醒顾客有新消息。广播的名字为 `UD_RECEIVED_NEW_MESSAGES_NOTIFICATION`，定义在 UdeskManager.h 中。

#### 6.14获取未读消息数量

开发者可以在需要显示未读消息数是调用此接口，当用户进入聊天界面后，未读消息将会清零。

```objective-c
[UdeskManager getLocalUnreadeMessagesCount];
```

#### 6.15获取未读消息

开发者可以在需要显示未读消息时调用此接口，当用户进入聊天界面后，未读消息将会清空。

```objective-c
[UdeskManager getLocalUnreadeMessages];
```

#### 6.16获取机器人URL

当前SDK的机器人是web网页来实现，通过此接口可以获取机器人网页的URL，在webview里打开后即可以与机器人对话。

```objective-c
[UdeskManager getRobotURL:^(NSURL *robotUrl) {
}];
```

#### 6.17判断客户是否正在会话

返回 yes/no 若返回NO则用户不在会话、返回YES则客户在客服的聊天列表中

```objective-c
BOOL isSession = [UdeskManager customersAreSession];
```
#### 6.18将所有未读消息设置为已读

可以把客户的未读消息重置

```objective-c
[UdeskManager markAllMessagesAsRead];
```

# 七、常见问题

#### 键盘弹起后输入框和键盘之间有偏移

请检查是否使用了第三方开源库[IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)，该开源库会和判断输入框的逻辑冲突。

- 在UdeskChatViewController的viewWillAppear里加入 `[[IQKeyboardManager sharedManager] setEnable:NO];`，作用是在当前页面禁止IQKeyboardManager
- 在UdeskChatViewController的viewWillDisappear里加入 `[[IQKeyboardManager sharedManager] setEnable:YES];`，作用是在离开当前页面之前重新启用IQKeyboardManager

#### **指定客服组或者客服分配出现与指定客服组客服不一致的情况**

先要确认客服没有关闭会话。

我们产品逻辑： 假设客户A   选了客服组B下的客服B1，进行会话。  之后客户A退出会话界面，进入另外界面，之后通过客服组C下的客服C 1分配会话：  这时后台会判断，如果和B1会话还存在，则会直接分配给B1，而不会分配給客服C 1。  只有B1会话关闭了，才会分配給客服C1。

#### 出现在不同客户分配的会话在一个会话中

出现这种情况，是客服传的sdktoken值一样。 sdktoken像身份证一样，是用户唯一的标识。让客户检查接入是传入的sdktoken值。

 如果设置了email 或者 cellphone  出现相同也会在一个客服的会话里。

# 八、更新记录

#### 更新记录：

sdk v3.6.3版本更新功能:

1.优化自定义字段调用方式

2.欢迎语bug修改

------

sdk v3.6.2版本更新功能:

1.增加im页面返回回调API

2.录音优化

------

sdk v3.6.1版本更新功能:

1.满意度调查多次弹窗bug修改

2.客服繁忙到上线sdk弹窗自动隐藏

------

sdk v3.6版本更新功能:

1.支持结构化消息展示

2.支持管理员端黑名单留言提示语自定义

------

sdk v3.5.8版本更新功能:

1.支持留言添加附件

2.开放留言页面跳转方式事件逻辑修改

3.推送例子

3.bug修复

------

sdk v3.5.7版本更新功能:

1.支持bitcode

------

sdk v3.5.6版本更新功能:

1.修改复制大量文字到输入框引起的crash

------

sdk v3.5.5版本更新功能:

1.支持将未读消息标记为已读

2.修复关闭会话之后有几率性不弹满意度调查

------

sdk v3.5.4版本更新功能:

1.适配iOS10.3

------

sdk v3.5.3版本更新功能:

1.支持管理员端sdk配置

2.支持放弃排队

3.初始化不再支持单点登录的key，统一使用创建每个应用时生成对应的appid，和appkey。

------

sdk v3.4版本更新功能:

1.支持推送

2.支持多app

3.新增查看客户是否正在会话API

4.满意度调查bug修复

------

sdk v3.3.4版本更新功能:

1.优化相册、语音权限流程

2.转接优化

------

sdk v3.3.3版本更新功能：

1.支持主动满意度调查

2.push接口增加完成回调

3.文字过多时计算bug修复

4.支持https

