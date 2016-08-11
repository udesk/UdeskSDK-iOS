# UdeskSDK-iOS
Udesk为了让开发者更好的集成移动SDK,与企业业务结合更加紧密，我们开源了SDK的UI界面。用户可以根据自身业务以及APP不同风格重写页面。当然开发者也可以直接用我们提供的默认的界面。


## 一、SDK工作流程


Udesk-SDK的工作流程如下图所示。

![udesk](http://7xr0de.com2.z0.glb.qiniucdn.com/ios-new-1.png)

## 二、导入SDK依赖的框架

#### 2.1文件介绍

| Demo中的文件      | 说明                |
| ------------- | ----------------- |
| UDChatMessage | Udesk提供的开源聊天界面    |
| SDK           | Udesk SDK的静态库和头文件 |
| Resource      | Udesk资源文件         |

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

#### 2.4CocoaPods 导入

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

```
UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];

[self.navigationController pushViewController:chat animated:YES];
```

#### 3.5推出机器人页面

确保管理员后后【管理中心-即时通讯-IM机器人】开启机器人SDK IM渠道。可以设置是否允许转人员。使用此界面，则会根据后台配置显示机器人或人工客服对话界面

```
UdeskRobotIMViewController *robot = [[UdeskRobotIMViewController alloc] init];

[self.navigationController pushViewController:robot animated:YES];
```
#### 3.4推出帮助中心

```
UdeskFaqController *faq = [[UdeskFaqController alloc] init];
[self.navigationController pushViewController:faq animated:YES];
```

#### 3.5推出客服导航

```
[UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {

if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {

NSArray *result = [responseObject objectForKey:@"result"];
//后台配置了客服导航，直接进入客服导航页面
if (result.count) { 
UdeskAgentNavigationMenu *agentMenu = [[UdeskAgentNavigationMenu alloc] initWithMenuArray:result];

[self.navigationController pushViewController:agentMenu animated:YES];
}
else {
//后台未配置了客服导航，进入默认聊天页面  
UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];
[self.navigationController pushViewController:chat animated:YES];
}
}

}];
```



## 四、Udesk SDK API说明

注意：以下接口在Udesk开源UI里均有调用，如果你使用Udesk的开源UI则不需要调用以下任何接口

#### 4.1初始化SDK

```
//初始化Udesk
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.    
[UdeskManager initWithAppkey:@"公司密钥" domianName:@"公司域名"];   
return YES;
}
```

#### 4.2初始化客户信息

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

##### 4.2.1添加客户自定义字段

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

**4.2.4创建用户**

此接口为必调用，否则无法使用SDK

```
[UdeskManager createCustomerWithCustomerInfo:parameters];
```

##### 4.2.2更新用户信息

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

#### **4.3**添加咨询对象

根据需求自定义，不调用不影响主流程

```
在你push事件的时候调用UdeskChatViewController类的 showProductViewWithDictionary方法

UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];
//咨询对象
NSDictionary *product =  @{
@"product_imageUrl":@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg",
@"product_title":@"测试咨询对象标题测试咨询对象标题！",
@"product_detail":@"¥88888.0",
@"product_url":@"http://www.baidu.com"

};

[chat showProductViewWithDictionary:product];

[self.navigationController pushViewController:chat animated:YES];
```

SDK 咨询对象展示:

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/%E5%92%A8%E8%AF%A2%E5%AF%B9%E8%B1%A1.png)



#### 4.4 获取当前客户的帐号信息

在用户创建成功后调用，会获取当前客户的帐号信息，但开发者不可见，在调用**连接Udesk服务器接口**时SDK会自动使用帐号信息，可参考开源UI相关步骤

[UdeskManager getCustomerLoginInfo:^(BOOL success, NSError *error) {

}];
#### 4.5请求分配客服

在获取当前客户的帐号信息后，调用此接口，请求分配客服，获得客服信息和以及排队信息，可参考开源UI

```
[UdeskManager requestRandomAgent:^(id responseObject, NSError *error) {  

//返回客服信息
}];
```

#### 4.6指定分配客服或客服组 

在获取当前客户的帐号信息后，调用此接口可主动指定分配客服和客服组，获得客服信息和以及排队信息，可参考开源UI

```
[UdeskManager assignAgentOrGroup:@"agentId" groupID:@"groupId" completion:^(id responseObject,      NSError *error) {

}];
```

**获取客服和客服组ID**

使用管理员登陆Udesk系统

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/%E8%8E%B7%E5%8F%96%E5%AE%A2%E6%9C%8Did.jpg)

#### 4.7连接Udesk服务器

获取分配的客服信息之后，调用此接口可以建立客户与Udesk服务器之间的连接

```
[UdeskManager loginUdesk:^(BOOL status) {
NSLog(@"登录Udesk成功");
}];
```

#### 4.8断开与Udesk服务器连接 

切换用户时，调用此接口断开上一个客户的连接

```
[UdeskManager logoutUdesk];
```

#### 4.9设置客户离线 

在客户点击home键后调用此方法，如不调用此方法，可能会造成客服消息发送不出去，或者是退出对话页面时调用。

```
[UdeskManager setCustomerOffline];
```

#### 4.10设置客户上线

连接Udesk服务器后客户默认在线，在设置客户离线后，调用此接口可以上客户重新上线。

```
[UdeskManager setCustomerOnline];
```

#### 4.11设置接收消息代理

设置接收消息的代理，由代理来接收消息。

设置代理后，实现 `UDManagerDelegate` 中的 `didReceiveMessages:` `didReceivePresence:` `didReceiveSurvey:withAgentId:` 方法，即可通过这些代理函数接收消息。

```
[UdeskManager receiveUdeskDelegate:self]; 
```

#### 4.12发送消息

调用此接口开发送各种类型的消息，注意选择正确的消息类型。

//message消息类型为 UdeskMessage
[UdeskManager sendMessage:message completion:^(UdeskMessage *message,BOOL sendStatus) {    

}];
#### 4.13输入预知

将用户正在输入的内容，实时显示在客服对话窗口。该接口没有调用限制，但每1秒内只会向服务器发送一次数据）

注意：需要在初始化成功后，且客服是在线状态时调用才有效

```
[UdeskManager sendClientInputtingWithContent:text];
```

#### 4.14获取客户本地聊天数据

```
[UdeskManager queryTabelWithSqlString:sql params:nil];
```

#### 4.15监听收到未读消息的广播

开发者可在合适的地方，监听收到消息的广播，用于提醒顾客有新消息。广播的名字为 `UD_RECEIVED_NEW_MESSAGES_NOTIFICATION`，定义在 UdeskManager.h 中。

#### 4.16获取未读消息数量

开发者可以在需要显示未读消息数是调用此接口，当用户进入聊天界面后，未读消息将会清零。

```
[UdeskManager getLocalUnreadeMessagesCount];
```

#### 4.17获取机器人URL

当前SDK的机器人是web网页来实现，通过此接口可以获取机器人网页的URL，在webview里打开后即可以与机器人对话。

```
[UdeskManager getRobotURL:^(NSURL *robotUrl) {
}];
```

