//
//  UdeskSDKConfig.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UdeskSDKStyle.h"
#import "UdeskCustomButtonConfig.h"
#import "UdeskEmojiPanelModel.h"

@class UdeskMessage;
@class UdeskGoodsModel;
@class UdeskChatViewController;
@class UdeskLocationModel;

//显示聊天窗口的动画
typedef NS_ENUM(NSUInteger, UDTransiteAnimationType) {
    UDTransiteAnimationTypePresent,
    UDTransiteAnimationTypePush
};

//小视频分辨率
typedef NS_ENUM(NSUInteger, UDSmallVideoResolutionType) {
    UDSmallVideoResolutionType640x480,
    UDSmallVideoResolutionType1280x720,
    UDSmallVideoResolutionType1920x1080,
    UDSmallVideoResolutionTypePhoto //最高分辨率
};

//语言类型枚举
typedef NS_ENUM(NSUInteger, UDLanguageType) {
    UDLanguageTypeCN,
    UDLanguageTypeEN
};

@interface UdeskSDKActionConfig : NSObject

/** 离线留言点击 */
@property (nonatomic, copy) void(^leaveMessageClickBlock)(UIViewController *viewController);

/** 结构化消息回调 */
@property (nonatomic, copy) void(^structMessageClickBlock)(NSString *value, NSString *callbackName);

/** 离开聊天页面回调 */
@property (nonatomic, copy) void(^leaveChatViewControllerBlock)(void);

/** 离开UdeskSDK所有页面回调 */
@property (nonatomic, copy) void(^leaveUdeskSDKBlock)(void);

/** 地理位置功能按钮回调 */
@property (nonatomic, copy) void(^locationButtonClickBlock)(UdeskChatViewController *viewController);

/** 地理位置消息回调 */
@property (nonatomic, copy) void(^locationMessageClickBlock)(UdeskChatViewController *viewController, UdeskLocationModel *locationModel);

/** 登陆成功 */
@property (nonatomic, copy) void(^loginSuccessBlock)(void);

/** 点击文本链接回调 */
@property (nonatomic, copy) void(^linkClickBlock)(UIViewController *viewController,NSURL *URL);

/** 商品消息回调 */
@property (nonatomic, copy) void(^goodsMessageClickBlock)(UdeskChatViewController *viewController,UdeskGoodsModel *goodsModel);

/** 咨询对象发送按钮回调 */
@property (nonatomic, copy) void(^productMessageSendLinkClickBlock)(UdeskChatViewController *viewController,NSDictionary *productMessage);

@end

@interface UdeskSDKConfig : NSObject

/*  ----------- 指定员工 ------------  */

/** 指定客服id */
@property (nonatomic, copy) NSString *agentId;
/** 指定客服组id */
@property (nonatomic, copy) NSString *groupId;
/** 导航栏客服组id（注意：不需要传这个参数，这个是本地记录用的） */
@property (nonatomic, copy) NSString *menuId;

/*  ----------- 自动消息 ------------  */

/** 进入聊天界面自动发送给客服的消息, 可以包括图片、文字、商品消息（传UdeskGoodsModel） */
@property (nonatomic, strong) NSArray *preSendMessages;

/*  ----------- 图片选择器 ------------  */

/** 是否开启图片选择器（默认开启） */
@property (nonatomic, assign, getter=isImagePickerEnabled) BOOL imagePickerEnabled;
/** 图片一次可选择数（默认9张） */
@property (nonatomic, assign) NSInteger maxImagesCount;
/** 压缩质量 0.1 - 1（默认0.5，选择原图发送压缩质量一直为1） */
@property (nonatomic, assign) CGFloat   quality;
/** 允许选择视频（默认允许） */
@property (nonatomic, assign, getter=isAllowPickingVideo) BOOL allowPickingVideo;

/*  ----------- 小视频 ------------  */

/** 是否开启小视频（默认开启） */
@property (nonatomic, assign, getter=isSmallVideoEnabled) BOOL smallVideoEnabled;
/** 小视频分辨率（默认最高分辨率） */
@property (nonatomic, assign) UDSmallVideoResolutionType smallVideoResolution;
/** 小视频录制时长（默认15s） */
@property (nonatomic, assign) CGFloat   smallVideoDuration;

/*  ----------- 自定义工具栏 ------------  */

/** 是否隐藏（默认隐藏，此参数只控制输入框上方的自定义按钮，不控制更多里的自定义按钮）*/
@property (nonatomic, assign, getter=isShowCustomButtons) BOOL showCustomButtons;
/** 是否在输入框上方的工具栏显示满意度评价（这个参数会和后台管理员配置是否开启满意度调查结合判断，同为true才显示。该参数默认为false） */
@property (nonatomic, assign, getter=isShowTopCustomButtonSurvey) BOOL showTopCustomButtonSurvey;
/** 自定义按钮 */
@property (nonatomic, strong) NSArray<UdeskCustomButtonConfig *> *customButtons;

/*  ----------- 其他功能 ------------  */

/** 是否隐藏语音 */
@property (nonatomic, assign, getter=isShowVoiceEntry) BOOL showVoiceEntry;
/** 是否隐藏表情 */
@property (nonatomic, assign, getter=isShowEmotionEntry) BOOL showEmotionEntry;
/** 是否隐藏相机 */
@property (nonatomic, assign, getter=isShowCameraEntry) BOOL showCameraEntry;
/** 是否隐藏相册 */
@property (nonatomic, assign, getter=isShowAlbumEntry) BOOL showAlbumEntry;
/** 是否隐藏定位 */
@property (nonatomic, assign, getter=isShowLocationEntry) BOOL showLocationEntry;
/** 是否隐藏发送视频（开启小视频默认允许发送视频） */
@property (nonatomic, assign, getter=isAllowShootingVideo) BOOL allowShootingVideo;

/*
 语言类型,推荐此方法.
 
 注意:
 1. 使用时请提前创建对应语言的语言包, 分为App端和和服务端.
 2. App端创建对应名称的lproj包, 用于一些本地语言的切换, 当前已经包含中文(zh-Hans.proj)和英文(en.lproj). 默认使用简体中文. 如果未创建, 则使用对应的key值
 3. 服务端创建对应的语言包, Api返回数据时根据配置来选择对应语言. 帮助文档:http://udesk.udesk.cn/hc/articles/46387. 如果未创建, 默认使用中文.
 4. 可配置服务端默认语言包, 如果未设置, 则使用此默认
 
 ar:阿拉伯语;
 en-us:英语; // 注意:App端对应en.lproj !!!!!!!!!
 es:西班牙语;
 fr:法语;
 ja:日语;
 ko:朝鲜语/韩语;
 th:泰语;
 id:印度尼西亚语;
 zh-TW:繁体中文;
 pt:葡萄牙语;
 ru:俄语;
 zh-cn:中文简体; // 注意:App端对应zh-Hans.proj !!!!!!!!!
 */
@property (nonatomic, copy  ) NSString *language;
/** 放弃排队模式：mark (默认,标记放弃)/ cannel_mark(取消标记) / force_quit(强制立即放弃) */
@property (nonatomic, copy  ) NSString *quitQueueMode;
/** 页面弹出方式 */
@property (nonatomic, assign) UDTransiteAnimationType presentingAnimation;

/** 咨询对象消息 */
@property (nonatomic, strong) NSDictionary *productDictionary;
/** sdk方向(默认只支持竖屏) */
@property (nonatomic, assign) UIInterfaceOrientationMask orientationMask;
/** 自定义表情 */
@property (nonatomic, strong) NSArray<UdeskEmojiPanelModel *> *customEmojis;

/** im标题 */
@property (nonatomic, copy) NSString *imTitle;
/** 机器人标题（显示优先级：管理员后台配置>自定义配置>默认配置） */
@property (nonatomic, copy) NSString *robotTtile;
/** 帮助中心标题 */
@property (nonatomic, copy) NSString *faqTitle;
/** 帮助中心文章标题 */
@property (nonatomic, copy) NSString *articleTitle;
/** 留言提交工单标题 */
@property (nonatomic, copy) NSString *ticketTitle;
/** 客服导航栏菜单标题 */
@property (nonatomic, copy) NSString *agentMenuTitle;
/** 导航栏返回按钮文字 */
@property (nonatomic, copy) NSString *backText;
/** 咨询对象按钮文字 */
@property (nonatomic, copy) NSString *productSendText;
/** 机器人会话欢迎语 */
@property (nonatomic, copy) NSString *robotWelcomeMessage;

/** SDK事件 */
@property (nonatomic, strong) UdeskSDKActionConfig *actionConfig;
/** SDK风格 */
@property (nonatomic, strong) UdeskSDKStyle *sdkStyle;

@property (nonatomic, strong) NSArray *udViewControllers;

+ (instancetype)customConfig;

- (void)setConfigToDefault;

@end
