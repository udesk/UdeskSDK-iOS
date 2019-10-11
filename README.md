# UdeskSDK-iOS
### 公告

SDK适配iOS11的版本是从3.7开始，如果还没升级到最新版本的请尽快升级

### SDK下载地址

https://github.com/udesk/UdeskSDK-iOS

## 目录
- [一、集成SDK](#%E4%B8%80%e9%9b%86%e6%88%90sdk)
- [二、快速使用SDK](#%E4%BA%8C%E5%BF%AB%E9%80%9F%E4%BD%BF%E7%94%A8sdk)
- [三、Udesk SDK 自定义配置](#%E4%B8%89udesk-sdk-%E8%87%AA%E5%AE%9A%E4%B9%89%E9%85%8D%E7%BD%AE)
- [四、消息推送](#%E5%9B%9B%E6%B6%88%E6%81%AF%E6%8E%A8%E9%80%81)
- [五、Udesk SDK API说明](#%E4%BA%94udesk-sdk-api%E8%AF%B4%E6%98%8E)
- [六、常见问题](#%E5%85%AD%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)
- [七、更新记录](#%E4%B8%83%E6%9B%B4%E6%96%B0%E8%AE%B0%E5%BD%95)
- [八、功能截图](#%E5%85%AB%E5%8A%9F%E8%83%BD%E6%88%AA%E5%9B%BE)




# 一、集成SDK

### 文件介绍

| Demo中的文件  | 说明                      |
| --------- | ----------------------- |
| UdeskSDK  | Udesk在线咨询SDK            |
| UdeskCall | Udesk视频会话SDK（依赖在线咨询SDK） |

##### **注意：UdeskSDK并不依赖UdeskCall，如果不需要此功能则不要导入该SDK。**

### 兼容性

| 类别     | 兼容范围                      |
| -------- | ----------------------------- |
| 系统     | 支持iOS 7.0及以上系统         |
| 架构     | armv7、arm64、i386、x86_64    |
| 开发环境 | 建议使用最新版本Xcode进行开发 |

### SDK大小说明

1. 由于 Bitcode 开启会导致二进制文件体积增大，这部分会在 AppStore 发布时进行进一步编译优化，并不会引起最终文件的体积变化，故此处计算的是关闭 Bitcode 下的二进制增量。
2. .a中是多个架构做了合并，使用lipo可以看到细节。所以.a库文件本身很大，且打包出来的ipa也相对较大。但用户实际下载到手机中会被AppStore优化，只下载用户设备需要的架构，所以实际在手机上占用的空间很小。`Architectures in the fat file: libUdesk.a are: armv7 i386 x86_64 arm64 `
3. DemoApp 在iPhoneX 12.1 中实际占用大小小于10M

### 导入UdeskSDK到工程

#### 1.1 手动导入

Udesk SDK 的实现，依赖了一些系统框架，在开发应用时，需要在工程里加入这些框架。开发者首先点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -> *BuiLd Phases* -> *Link Binary With Libraries*，展开 *LinkBinary With Libraries* 后点击展开后下面的 *+* 来添加下面的依赖项:

```
libz.tbd
libxml2.tbd
libresolv.tbd
libsqlite3.tbd
WebKit.framework
MapKit.framework
AssetsLibrary.framework
ImageIO.framework
Accelerate.framework
MediaPlayer.framework
Photos.framework
CoreText.framework
```

把下载的文件夹中的UdeskSDK文件夹拖到你的工程里，并进行以下配置

- 点击的你工程targets->Build Settings 
- 搜索Other Linker Flags 加入 -lxml2 -ObjC
- 搜索header search paths 加入/usr/include/libxml2

#### 1.2 CocoaPods 导入

在 Podfile 中加入：

```objective-c
pod 'UdeskSDK'
```
执行命令：

```ruby
//更新本地Cocoapods仓库
$ pod repo update
//更新Podfile里的第三方库
$ pod update
```

在 控制器 中引入：

```objective-c
//Objective-C
#import "Udesk.h"
//swift
import UdeskSDK
```

#### 权限问题

SDK使用了iOS的相册、相机、麦克风、地理位置、保存图片功能，请在info.plist里加入相对应的权限

### 导入UdeskCall到工程

把下载的文件夹中的UdeskCall文件夹拖到你的工程里，并进行以下配置

- pod 'AgoraRtcEngine_iOS', '~> 2.0.2' 

导入系统框架

```objective-c
libicucore.tbd
CFNetwork.framework
Security.framework
```

**注意：UdeskCall最低支持iOS8.0，不支持bitcode，请在info.plist里配置后台运行模式**



# 二、快速使用SDK

Udesk提供了一套开源的聊天界面，帮助开发者快速创建对话窗口和帮助中心，并提供自定义接口，以实现定制需求。

### 2.1 初始化公司和客户信息

```objective-c
//初始化公司（appKey、appID、domain都是必传字段）
UdeskOrganization *organization = [[UdeskOrganization alloc] initWithDomain:"domain" appKey:"appKey" appId:"appId"];

//注意sdktoken 是客户的唯一标识，用来识别身份,是你们生成传入给我们的。
//sdk_token: 传入的字符请使用 字母 / 数字 等常见字符集 。就如同身份证一样，不允许出现一个身份证号对应多个人，或者一个人有多个身份证号;其次如果给顾客设置了邮箱和手机号码，也要保证不同顾客对应的手机号和邮箱不一样，如出现相同的，则不会创建新顾客。
UdeskCustomer *customer = [UdeskCustomer new];
//必填（请不要使用特殊字符）
customer.sdkToken = @"sdkToken";
//非必填可选主键，唯一客户外部标识，用于处理 唯一标识冲突 （请不要随意传值）
customer.customerToken = @"customerToken";
//非必填
customer.nickName = @"测试名字";
//需要严格按照邮箱规则（没有则不填，不可以为空）
customer.email = @"test@udesk.cn";
//需要严格按照号码规则（没有则不填，不可以为空）
customer.cellphone = @"18888888888";
customer.customerDescription = @"我是测试";

//客户自定义字段（非必填）
UdeskCustomerCustomField *textField = [UdeskCustomerCustomField new];
textField.fieldKey = @"TextField_390";
textField.fieldValue = @"测试";
        
UdeskCustomerCustomField *selectField = [UdeskCustomerCustomField new];
selectField.fieldKey = @"SelectField_455";
selectField.fieldValue = @[@0];
        
customer.customField = @[textField,selectField];

//初始化sdk
[UdeskManager initWithOrganization:organization customer:customer];
```

- domain为贵公司注册Udesk，Udesk分配的域名，domain格式为 xxx.udesk.cn 不需要添加https://
- appKey和appId可以在 “管理后台”  ->  “管理中心”  ->  “渠道管理” ->  “移动 SDK”，新增App即可获得
- fieldKey可以在 “管理后台”  ->  “管理中心”  ->  “管理”  ->  “客户字段” 获得

### 2.2 进入聊天页面

```objective-c
//使用push
UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:[UdeskSDKConfig customConfig]];
[sdkManager pushUdeskInViewController:self completion:nil];

//使用present
[sdkManager presentUdeskInViewController:self completion:nil];
```

### 2.3 进入帮助中心

```objective-c
//使用push
UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:[UdeskSDKConfig customConfig]];
[sdkManager pushUdeskInViewController:self udeskType:UdeskFAQ completion:nil];

//使用present
[sdkManager presentUdeskInViewController:self udeskType:UdeskFAQ completion:nil];
```

- ##### [UdeskSDKStyle defaultStyle] 是 SDK默认的UI风格，用户可自定义风格，具体可[点击查看](#%E4%B8%89udesk-sdk-%E8%87%AA%E5%AE%9A%E4%B9%89%E9%85%8D%E7%BD%AE)

- ##### [UdeskSDKConfig customConfig] 是 SDK的配置选项，具体可[点击查看](#%E4%B8%89udesk-sdk-%E8%87%AA%E5%AE%9A%E4%B9%89%E9%85%8D%E7%BD%AE)



# 三、Udesk SDK 自定义配置

### 3.1 使用SDK提供的UI

#### 原生

```objective-c
UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
[sdkManager pushUdeskInViewController:self completion:nil];
```
#### 经典


```objective-c
UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle blueStyle]];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.2 自定义UI

```objective-c
//此处只是示例，更多UI参数请参看 UdeskSDKStyle.h
UdeskSDKStyle *sdkStyle = [UdeskSDKStyle customStyle];
sdkStyle.navigationColor = [UIColor yellowColor];
sdkStyle.titleColor = [UIColor orangeColor];

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:sdkStyle];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.3 指定客服ID

##### 注意：如果在代码中指定了客服或者客服组需要在后台SDK配置中关闭导航菜单防止两者冲突。

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
sdkConfig.agentId = @"agentId";

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```
### 3.4 指定客服组ID

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
sdkConfig.groupId = @"groupId";

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.5 设置用户头像

```objective-c
UdeskSDKStyle *sdkStyle = [UdeskSDKStyle customStyle];
//通过本地图片设置头像
sdkStyle.customerImage = [UIImage imageNamed:@"avatar"];
//通过URL设置头像
sdkStyle.customerImageURL = @"https://avatar....";

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:sdkStyle];
[sdkManager pushUdeskInViewController:self completion:nil];
```
### 3.6 设置SDK语言

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//中文
sdkConfig.languageType = UDLanguageTypeCN;
//英文
//sdkConfig.languageType = UDLanguageTypeEN;

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.7 设置放弃排队类型

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//直接从排列中清除
sdkConfig.quitQueueType = UdeskForceQuit;
//标记放弃
//sdkConfig.quitQueueType = UdeskMark;

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.8 强制横/竖屏

#### 注意：iPad需要把Requires full screen勾选上

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//强制竖屏
sdkConfig.orientationMask = UIInterfaceOrientationMaskPortrait;
//强制横屏
//sdkConfig.orientationMask = UIInterfaceOrientationMaskLandscape;

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
//强制横/竖屏，只能使用presentUdeskInViewController方法
[sdkManager presentUdeskInViewController:self completion:nil];
```

### 3.9 设置自定义按钮

```objective-c
//按钮位于输入框上方
UdeskCustomButtonConfig *customButton1 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"自定义按钮" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
	//do something
    //UdeskChatViewController 有可以发送消息的方法。
}];

//按钮位于更多
UdeskCustomButtonConfig *customButton2 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"自定义按钮" image:[UIImage imageNamed:@"image.png"] type:UdeskCustomButtonConfigTypeInMoreView clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
	//do something
}];

UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//显示自定义按钮（默认隐藏，此参数只控制输入框上方的自定义按钮，不控制更多里的自定义按钮）
sdkConfig.showCustomButtons = YES;
//是否在输入框上方的工具栏显示满意度评价（这个参数会和后台管理员配置是否开启满意度调查结合判断，同为true才显示。该参数默认为false）
sdkConfig.showTopCustomButtonSurvey = YES;
sdkConfig.customButtons = @[customButton1,customButton2];

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.10 自动发送消息

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
sdkConfig.preSendMessages = @[@"testPreMessage",[UIImage imageNamed:@"image"]];

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.11 自定义表情

```objective-c
UdeskEmojiPanelModel *model = [UdeskEmojiPanelModel new];
//必填
model.emojiIcon = [UIImage imageNamed:@"likeSticker"];
model.stickerPaths = @[
                       [[NSBundle mainBundle] pathForResource:@"angry"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"cry"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"dead"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"embarrass"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"happy"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"joy"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"love"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"sad"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"shy"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"sleepy"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"surprise"ofType:@"png"],
                       [[NSBundle mainBundle] pathForResource:@"wink"ofType:@"png"],
                       ];
//非必填
model.stickerTitles = @[@"愤怒",@"哭泣",@"糟糕",@"冷汗",@"大笑",@"可爱",@"爱",@"流汗",@"害羞",@"睡觉",@"惊讶",@"调皮"];

UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
sdkConfig.customEmojis = @[model];

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.12 小视频功能

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//小视频功能默认开启
sdkConfig.smartVideoEnabled = YES;
//小视频分辨率
sdkConfig.videoResolution = UDSmatrVideoResolution1280x720;
//小视频录制时长
sdkConfig.smartVideoDuration = 30;

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.13 配置机器人推荐问题

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//robotModelKey由Udesk管理员后台配置获取
sdkConfig.robotModelKey = @"TestKey";

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.14 配置机器人客户信息

##### 注意：传入的客户信息需要与你初始化SDK时传入的客户信息一致。

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//robotCustomerInfo配置规则可参考Demo中的UdeskRobotCustomInfoViewController.m文件
sdkConfig.robotCustomerInfo = @"robotCustomerInfo";

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

#### 客户参数

| 参数名称              | 类型   | 值                                     | 是否必选 | 说明                                         |
| --------------------- | ------ | -------------------------------------- | -------- | -------------------------------------------- |
| c_name                | String | 客户姓名                               | 否       |                                              |
| c_email               | String | 客户邮箱`唯一`                         | 否       |                                              |
| c_phone               | String | 客户电话`唯一`                         | 否       |                                              |
| c_desc                | String | 客户描述                               | 否       |                                              |
| c_org                 | String | 公司名称                               | 否       |                                              |
| c_tags                | String | 客户标签                               | 否       | 传入客户标签，用逗号分隔 如："帅气,漂亮"     |
| c_owner               | String | 客户负责人ID                           | 否       |                                              |
| c_vip                 | String | 'vip'(vip客户) 或者 'normal'(普通客户) | 否       | 客户vip识别                                  |
| c_owner_group         | String | 客户负责组ID                           | 否       |                                              |
| c_other_emails        | String | 客户其他邮箱列表                       | 否       | 逗号分隔 如："a@xxx.cn,b@xxx.cn"             |
| c_cf_<自定义字段名称> | String | 客户自定义字段                         | 否       | 客户自定义字段 如： c_cf_名字、c_cf_age、... |

### 3.15 添加咨询对象

```objective-c
NSDictionary *dict = @{
                        @"productImageUrl":@"http://test.url.com/image.jpg",
                        @"productTitle":@"测试测试测试测你测试试测你！",
                        @"productDetail":@"¥88888.0",
                        @"productURL":@"http://www.baidu.com"
                       };
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
sdkConfig.productDictionary = dict;

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.16 商品消息

```objective-c
UdeskSDKConfig *config = [UdeskSDKConfig customConfig];
config.showCustomButtons = YES;

UdeskCustomButtonConfig *customButton = [[UdeskCustomButtonConfig alloc] initWithTitle:@"自定义按钮" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
	//发送商品消息（示例点击按钮直接发送商品消息，用户可根据自身需求进行修改）
    [viewController sendGoodsMessageWithModel:[self getGoodsModel]];
}];

config.customButtons = @[customButton];
    
UdeskSDKActionConfig *action = [UdeskSDKActionConfig new];
action.goodsMessageClickBlock = ^(UdeskChatViewController *viewController, NSString *goodsURL, NSString *goodsId) {
    //示例直接跳转浏览器，用户可根据自身需求进行修改
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:goodsURL]];
};
    
//初始化sdk
UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:config sdkActionConfig:action];
[chatViewManager pushUdeskInViewController:self completion:nil];

- (UdeskGoodsModel *)getGoodsModel {
    
    UdeskGoodsModel *goodsModel = [[UdeskGoodsModel alloc] init];
    goodsModel.name = @"Apple iPhone X (A1903) 64GB 深空灰色 移动联通4G手机";
    goodsModel.url = @"https://item.jd.com/6748052.html";
    goodsModel.imgUrl = @"http://img12.360buyimg.com/n1/s450x450_jfs/t10675/253/1344769770/66891/92d54ca4/59df2e7fN86c99a27.jpg";
    
    UdeskGoodsParamModel *paramModel1 = [UdeskGoodsParamModel new];
    paramModel1.text = @"￥6999.00";
    paramModel1.color = @"#FF0000";
    paramModel1.fold = @(1);
    paramModel1.udBreak = @(1);
    paramModel1.size = @(14);
    
    UdeskGoodsParamModel *paramModel2 = [UdeskGoodsParamModel new];
    paramModel2.text = @"满1999元立减30元";
    paramModel2.color = @"#c2fcc3";
    paramModel2.fold = @(1);
    paramModel2.size = @(12);
    
    UdeskGoodsParamModel *paramModel3 = [UdeskGoodsParamModel new];
    paramModel3.text = @"还有优惠券";
    paramModel3.color = @"#ffffff";
    paramModel3.fold = @(1);
    paramModel3.size = @(20);
    
    goodsModel.params = @[paramModel1,paramModel2,paramModel3];

    return goodsModel;
}
```

### 3.17 图片选择器

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
//是否开启图片选择器（默认开启），关闭则使用系统相册
sdkConfig.imagePickerEnabled = YES;
//最大选择图片数量（开启状态）
sdkConfig.maxImagesCount = 1;
//是否支持选择视频（开启状态）
sdkConfig.allowPickingVideo = NO;
//压缩质量 0.1-1（开启状态）
sdkConfig.quality = 0.5f;
    
//初始化sdk
UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

### 3.18 打开发送定位功能

```objective-c
UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
sdkConfig.showLocationEntry = YES;
    
//初始化sdk
UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

##### 自iOS8起，开发者在使用定位功能之前，需要在info.plist里添加（以下二选一，两个都添加默认使用NSLocationWhenInUseUsageDescription）：

##### NSLocationWhenInUseUsageDescription ，允许在前台使用时获取GPS的描述

##### NSLocationAlwaysUsageDescription ，允许永久使用GPS的描述

### 3.19 SDK事件回调

```objective-c
UdeskSDKActionConfig *actionConfig = [UdeskSDKActionConfig new];

//完全离开sdk页面回调
actionConfig.leaveUdeskSDKBlock = ^{
    //do something
};
//离开人工IM页面回调
actionConfig.leaveChatViewControllerBlock = ^{
    //do something
};
//登录成功回调
actionConfig.loginSuccessBlock = ^{
    //do something
};
//点击超链接回调
actionConfig.linkClickBlock = ^(UIViewController *viewController, NSURL *URL) {
    //do something
};
//点击结构化消息回调
actionConfig.structMessageClickBlock = ^{
    //do something
};
//点击离线留言按钮回调（实现该回调则放弃sdk原生离线留言功能）
actionConfig.leaveMessageClickBlock = ^(UIViewController *viewController) {
    //do something
};
//点击地理位置按钮回调（实现该回调则放弃sdk原生地理位置功能）
actionConfig.locationButtonClickBlock = ^(UdeskChatViewController *viewController) {
    //do something
};
//点击地理位置消息回调（实现该回调则放弃sdk原生地理位置功能）
actionConfig.locationMessageClickBlock = ^(UdeskChatViewController *viewController, UdeskLocationModel *locationModel) {
    //do something
};

UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:[UdeskSDKConfig customConfig] sdkActionConfig:actionConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```

#### **其他自定义配置请查看代码文件 “UdeskSDKConfig”**

#### **其他UI配置请查看代码文件 “UdeskSDKStyle”**



# 四、消息推送

当前仅支持一种推送方案，即Udesk服务端发送消息至开发者的服务端，开发者再推送消息到 App。

未来Udesk iOS SDK 将会支持直接推送消息给 App，即开发者可上传 App 的推送证书至Udesk，Udesk将推送消息至苹果 APNS 服务器。

### 设置接收推送的服务器地址

推送消息将会发送至开发者的服务器。

设置推送服务器地址，请使用Udesk管理员帐号登录 Udesk，在「设置」 -> 「移动SDK」中设置。

![udesk](http://7xr0de.com1.z0.glb.clouddn.com/5D761252-3D9D-467C-93C9-8189D0B22424.png)



### 上传设备的 deviceToken

App 进入后台后，Udesk推送给开发者服务端的消息数据格式中，会有 deviceToken 的字段。

将下列代码添加到 `AppDelegate.m` 中系统回调 `didRegisterForRemoteNotificationsWithDeviceToken`中：

注意：如果你用的是第三方推送，则要传入的是第三方推送生成的token。例如：极光推送生成registrationID。

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



# 五、Udesk SDK API说明

注意：以下接口在Udesk开源UI里均有调用，如果你使用Udesk的开源UI则不需要调用以下任何接口

### 5.1 更新用户信息

根据需求自定义，不调用不影响主流程

注意：

- 请不要使用已经存在的邮箱或者手机号进行更新，否则会更新失败！

```objective-c
 UdeskCustomer *customer = [UdeskCustomer new];
 customer.sdkToken = sdk_token;
 customer.nickName = @"我是udesk测试(可以随时把我关闭)";
 customer.email = @"test@udesk.cn";
 customer.cellphone = @"18888888888";
 customer.customerDescription = @"我是测试";
 
 UdeskCustomerCustomField *textField = [UdeskCustomerCustomField new];
 textField.fieldKey = @"TextField_390";
 textField.fieldValue = @"测试";
 
 UdeskCustomerCustomField *selectField = [UdeskCustomerCustomField new];
 selectField.fieldKey = @"SelectField_455";
 selectField.fieldValue = @[@"1"];
 
 customer.customField = @[textField,selectField];

 [UdeskManager updateCustomer:customer];
```

### 5.2 断开与Udesk服务器连接 

切换用户时，调用此接口断开上一个客户的连接

```objective-c
[UdeskManager logoutUdesk];
```

### 5.3 设置客户上线

连接Udesk服务器后客户默认在线，在设置客户离线后，调用此接口可以上客户重新上线。

```objective-c
[UdeskManager setupCustomerOnline];
```

### 5.4 设置客户离线

设置客户离线。

```objective-c
[UdeskManager setupCustomerOffline];
```

### 5.5 获取客户本地聊天数据

```objective-c
[UdeskManager getHistoryMessagesFromDatabaseWithMessageDate:[NSDate date] messagesNumber:20 result:^(NSArray *messagesArray) {
        
}];
```

### 5.6 删除客户本地聊天数据

```objective-c
[UdeskManager removeAllMessagesFromDatabase];
```

### 5.7 获取未读消息数量

开发者可以在需要显示未读消息数是调用此接口，当用户进入聊天界面后，未读消息将会清零。

```objective-c
[UdeskManager getLocalUnreadeMessagesCount];
```

### 5.8 获取未读消息

开发者可以在需要显示未读消息时调用此接口，当用户进入聊天界面后，未读消息将会清空。

```objective-c
[UdeskManager getLocalUnreadeMessages];
```

### 5.9 将所有未读消息设置为已读

可以把客户的未读消息重置

```objective-c
[UdeskManager markAllMessagesAsRead];
```

### 5.10 监听收到未读消息的广播

开发者可在合适的地方，监听收到消息的广播，用于提醒顾客有新消息。广播的名字为 `UD_RECEIVED_NEW_MESSAGES_NOTIFICATION`，定义在 UdeskManager.h 中。

### 5.11 判断客户是否正在会话

返回 yes/no 若返回NO则用户不在会话、返回YES则客户在客服的聊天列表中

```objective-c
BOOL isSession = [UdeskManager customersAreSession];
```
### 5.12 SDK支持发送地址位置

注：自iOS8起，开发者在使用定位功能之前，需要在info.plist里添加（以下二选一，两个都添加默认使用NSLocationWhenInUseUsageDescription）：

NSLocationWhenInUseUsageDescription ，允许在前台使用时获取GPS的描述

NSLocationAlwaysUsageDescription ，允许永久使用GPS的描述



SDK默认不可以发送地理位置，如果需要SDK发送地理位置

#### 原生（SDK内部自己实现定位、发送、搜索、查看，用的是苹果自带的原生地图控件）

[参考3.15](#%E4%B8%89udesk-sdk-%E8%87%AA%E5%AE%9A%E4%B9%89%E9%85%8D%E7%BD%AE)

#### API（通过API回调的方式接入地理位置，需要开发者自己实现相应功能，SDKDemo里有提供一个百度地图的示例，仅供参考。）

```objective-c
UdeskSDKActionConfig *actionConfig = [UdeskSDKActionConfig new];

//点击地理位置按钮回调（实现该回调则放弃sdk原生地理位置功能）
actionConfig.locationButtonClickBlock = ^(UdeskChatViewController *viewController) {
    //打开地理位置VC
   UdeskCustomLocationViewController *custom = [[UdeskCustomLocationViewController alloc] initWithHasSend:NO];
   UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:custom];
   [viewController presentViewController:nav animated:YES completion:nil];
   //地理位置VC 发送回调
   custom.sendLocationBlock = ^(UdeskLocationModel *model) {
       [viewController sendLoactionMessageWithModel:model];
   };
};
//点击地理位置消息回调（实现该回调则放弃sdk原生地理位置功能）
actionConfig.locationMessageClickBlock = ^(UdeskChatViewController *viewController, UdeskLocationModel *locationModel) {
    //打开地理位置VC
    UdeskCustomLocationViewController *custom = [[UdeskCustomLocationViewController alloc] initWithHasSend:YES];
  	//把需要查看的model传入
    custom.locationModel = locationModel;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:custom];
    [viewController presentViewController:nav animated:YES completion:nil];
};

UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
sdkConfig.showLocationEntry = YES;
    
UdeskSDKManager *sdkManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig sdkActionConfig:actionConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
```



# 六、常见问题

### 键盘弹起后输入框和键盘之间有偏移

请检查是否使用了第三方开源库[IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)，该开源库会和判断输入框的逻辑冲突。

- 在UdeskChatViewController的viewWillAppear里加入 `[[IQKeyboardManager sharedManager] setEnable:NO];`，作用是在当前页面禁止IQKeyboardManager
- 在UdeskChatViewController的viewWillDisappear里加入 `[[IQKeyboardManager sharedManager] setEnable:YES];`，作用是在离开当前页面之前重新启用IQKeyboardManager

### **指定客服组或者客服分配出现与指定客服组客服不一致的情况**

先要确认客服没有关闭会话。

我们产品逻辑： 假设客户A   选了客服组B下的客服B1，进行会话。  之后客户A退出会话界面，进入另外界面，之后通过客服组C下的客服C 1分配会话：  这时后台会判断，如果和B1会话还存在，则会直接分配给B1，而不会分配給客服C 1。  只有B1会话关闭了，才会分配給客服C1。

### 出现在不同客户分配的会话在一个会话中

出现这种情况，是客服传的sdktoken值一样。 sdktoken像身份证一样，是用户唯一的标识。让客户检查接入是传入的sdktoken值。

 如果设置了email 或者 cellphone  出现相同也会在一个客服的会话里。

### 出现类似异常+[UDXMLElement elementWithName:xmlns:]: unrecognized selector sent to class 0x10112abb8

出现这种情况，请先检查手动导入时Xcode工程里的配置是否完善（参考2.2和2.3）。

如果确认配置没有问题，请查看Other Linker Flags里是否写了-force_load，如果有写这个配置请在这个配置下面加入我们sdk .a文件的地址。

### APP使用百度地图，进入SDK会话页面直接崩溃，崩溃信息显示 "xmlFreeDoc"

出现这种情况，请检查使用的百度地图SDK版本是否是为3.4.2。请升级百度地图SDK到最新版本。

### APP使用友盟分享无法正常跳转

升级友盟SDK到最新版本。

### 客服消息发送一直在转圈

SDK在退到后台之后不会马上离线，会导致客服发送消息一直发不出去，只有在SDK离线之后会发送离线消息。

可以在APP退到后台的时候主动调用下我们的离线方法

```objective-c
[UdeskManager setupCustomerOffline];
```

在APP进入到前台的时候主动调用下我们的上线方法

```objective-c
[UdeskManager setupCustomerOnline];
```

### APP旋转屏幕 SDK UI没有适配问题

SDK暂时还没有支持旋转的UI适配，下面是解决办法

```objective-c
UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
//强制竖屏
chatViewManager.orientationMask = UIInterfaceOrientationMaskPortrait;
//强制横屏
//chatViewManager.orientationMask = UIInterfaceOrientationMaskLandscape;
[chatViewManager presentUdeskInViewController:self completion:nil];
```

### H5页面无法上传附件，点击直接返回翻一页

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

### 工作台顾客信息显示应用的名称不正确

如果工作台的客户信息 - 来源显示的是「未知」，则可能是您的 App 的 info.plist 中没有设置 CFBundleDisplayName 这个 Property，导致 SDK 获取不到 App 的名字。

# 七、更新记录

#### 更新记录：

sdk v4.3.1版本更新功能:

1.修改上传文件策略

2.修改了在黑暗模式下的显示问题

------

sdk v4.3.0版本更新功能:

1.修复了YYWebImage冲突问题

2.修复了客服状态问题

3.修复了获取多语言应用名称问题

4.限制了满意度评价备注字数

5.修复了已知问题

------

sdk v4.1.9版本更新功能:

1.修复了YYWebImage冲突问题

------

sdk v4.1.8版本更新功能:

1.修复了泰文消息显示不全的问题

------

sdk v4.1.7版本更新功能:

1.适配iOS13

2.修复了已知问题

------

sdk v4.1.6版本更新功能:

1.修复了图片选择器错乱问题

2.空消息优化

3.修复了已知问题

------

sdk v4.1.5版本更新功能:

1.修复了无消息对话过滤在某些场景下失效的问题

2.修复了使用sdk指定客服/客服组在某些场景下失效的问题

------

sdk v4.1.4版本更新功能:

1.多语言支持

2.稳定性优化

------

sdk v4.1.3版本更新功能:

1.消息优化

------

sdk v4.1.2版本更新功能:

1.客服连接逻辑优化

2.视频消息下载优化

3.稳定性优化

------

sdk v4.1.1版本更新功能:

1.修复了在无消息对话过滤界面发送表情显示code问题

2.修复了偶发出现配置英文还提示中文弹窗的问题

------

sdk v4.1.0版本更新功能:

1.机器人支持自动转人工事件

2.适配iPhone Xs、XR、Xs Max

3.支持全局客户唯一性customer_token

4.支持自定义渠道

5.机器人名称支持管理员后台配置

6.优化无消息对话过滤

7.离线消息优化显示消息时间为发送时间

8.默认表情替换、兼容新旧表情

9.支持排队发送消息

10.修复了不同手机视频消息无法播放问题

11.修复了客服快送发送消息导致sdk端消息排序错乱问题

12.修复了选择多张图片发送导致图片发送不准确问题

13.已知问题修复

------

sdk v4.0.6版本更新功能:

1.适配iOS12 

------

sdk v4.0.5版本更新功能:

1.更新客户信息支持回调 

2.满意度调查UI适配iPhone X 

3.网络检查组件“UdeskReachability” crash修复

------

sdk v4.0.4版本更新功能:

1.消息优化

2.评价结果错误问题修改

3.满意度评价第三方输入法遮挡提交按钮问题修改

4.sdk 相机权限提示优化

5.SDK满意度标签选中后，键盘弹出收起时，标签选中标识消失 

------

sdk v4.0.3版本更新功能:

1.排队直接进入留言问题修改 

2.满意度评价备注必填问题修改

------

sdk v4.0.2版本更新功能:

1.连接优化

2.修复无法直接留言问题

3.修复直接留言文案显示又消失问题

4.修复无消息对话过滤无法收到自动消息问题

------

sdk v4.0.1版本更新功能:

1.支持商品消息

2.已知问题修改

------

sdk v4.0.0版本更新功能:

1.支持新版满意度调查

2.支持自定义按钮

3.支持无消息对话过滤

4.支持强制横竖屏

5.支持后台配置留言引导文案

6.支持小视频拍摄

7.选择图片优化

8.支持自定义表情包

9.支持配置机器人推荐问题

10.支持配置转人工按钮在机器人会话x条后显示

11.支持自动发送消息

------

sdk v3.9.2版本更新功能:

1.修复了接收富文本消息有几率崩溃问题

------

sdk v3.9.1版本更新功能:

1.工单页面、地理位置页面适配iPhone X

2.工单页面、地理位置页面白线问题处理

3.修复分配客服组问题

4.修复引入的第三方框架枚举冲突

------

sdk v3.9版本更新功能:

1.消息到达率优化

2.SDK支持视频会话

------

sdk v3.8.7版本更新功能:

1.增加消息文本网址点击回调接口

2.修复调用.searchController导致的crash问题

3.修复进入留言表单用户默认数据不会自动带入问题

------

sdk v3.8.6版本更新功能:

1.机器人页面适配iPhone X

2.放弃排队优化

3.解决输入文字换行出现的UI问题

4.修改拍摄图片过大导致花屏的问题

------

sdk v3.8.5版本更新功能:

1.满意度调查不弹窗bug修改

------

sdk v3.8.4版本更新功能:

1.增加获取后端配置失败重试机制

2.适配iPhone X

3.增加设置系统相册取消按钮颜色参数

------

sdk v3.8.3版本更新功能:

1.SDK在非工作时间直接留言失败问题修改

2.视频重发问题修改

------

sdk v3.8.2版本更新功能:

1.iOS11导航栏按钮偏移问题修改

------

sdk v3.8.1版本更新功能:

1.修复sdk_token特殊字符导致消息无法保存问题

------

sdk v3.8版本更新功能:

1.SDK支持地理位置发送（支持原生和API形式）

2.欢迎语支持电话网址识别

3.解决pod导入中英文切换问题

4.解决APP切换网络SDK不会相应传给客服修改问题

------

sdk v3.7.1版本更新功能:

1.欢迎语空白bug修改

2.时间显示bug修改

3.指定分配客服、客服组bug修改

4.使用导入pod 和YYWebimage冲突修改

5.输入框功能按钮可配置

6.根据iOS版本切换使用WKWebview或者UIWebview

------

sdk v3.7版本更新功能:

1.支持离线直接留言

2.SDK支持返回满意度调查和支持开关设置

3.SDK支持接收和发送GIF

4.SDK支持接收和发送视频

5.SDK支持客服消息撤回

------

sdk v3.6.4版本更新功能:

1.客服关闭会话之后用户发送消息重连机制

2.关闭留言弹窗文案bug修改

------

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

# 八、功能截图

以下是SDK部分功能截图

### 商品消息
![udesk](https://qn-im.udesk.cn/QQ20180927-105917_1538017915_503.png)

### 咨询对象
![udesk](https://qn-im.udesk.cn/QQ20180927-105034_1538017914_750.png)

### 自定义表情
![udesk](https://qn-im.udesk.cn/QQ20180927-104429_1538017914_710.png)

### 自定义按钮
![udesk](https://qn-im.udesk.cn/QQ20180927-104341_1538029819_848.png)

### 地理位置和视频消息
![udesk](https://qn-im.udesk.cn/2221538017487_.pic_hd_1538027283_385.png)



