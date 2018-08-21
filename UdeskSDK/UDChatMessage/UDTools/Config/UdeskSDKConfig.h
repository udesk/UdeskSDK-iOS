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

// 排队放弃类型枚举
typedef NS_ENUM(NSUInteger, UDQuitQueueType) {
    /** 直接从排列中清除 */
    UDQuitQueueTypeForce,
    /** 标记放弃 */
    UDQuitQueueTypeForceMark
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
@property (nonatomic, copy) void(^goodsMessageClickBlock)(UdeskChatViewController *viewController,NSString *goodsURL,NSString *goodsId);

/** 咨询对象发送按钮回调 */
@property (nonatomic, copy) void(^productMessageSendLinkClickBlock)(UdeskChatViewController *viewController,NSDictionary *productMessage);

@end

@interface UdeskSDKConfig : NSObject

/*  ----------- 指定员工 ------------  */

/** 指定客服id */
@property (nonatomic, copy) NSString *agentId;
/** 指定客服组id */
@property (nonatomic, copy) NSString *groupId;

/*  ----------- 自动消息 ------------  */

/** 进入聊天界面自动发送给客服的消息, 可以包括图片和文字 */
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


/** 放弃排队方式 */
@property (nonatomic, assign) UDQuitQueueType quitQueueType;
/** 语言类型 */
@property (nonatomic, assign) UDLanguageType languageType;
/** 页面弹出方式 */
@property (nonatomic, assign) UDTransiteAnimationType presentingAnimation;

/** 咨询对象消息 */
@property (nonatomic, strong) NSDictionary *productDictionary;
/** sdk方向(默认只支持竖屏) */
@property (nonatomic, assign) UIInterfaceOrientationMask orientationMask;
/** 机器人推荐问题（后台配置获取key） */
@property (nonatomic, copy  ) NSString  *robotModelKey;
/** 机器人客户信息 */
@property (nonatomic, copy  ) NSString  *robotCustomerInfo;
/** 自定义表情 */
@property (nonatomic, strong) NSArray<UdeskEmojiPanelModel *> *customEmojis;

/** im标题 */
@property (nonatomic, copy) NSString *imTitle;
/** 机器人标题 */
@property (nonatomic, copy) NSString *robotTtile;
/** 帮助中心标题 */
@property (nonatomic, copy) NSString *faqTitle;
/** 帮助中心文章标题 */
@property (nonatomic, copy) NSString *articleTitle;
/** 留言提交工单标题 */
@property (nonatomic, copy) NSString *ticketTitle;
/** 客服导航栏菜单标题 */
@property (nonatomic, copy) NSString *agentMenuTitle;
/** 返回按钮文字 */
@property (nonatomic, copy) NSString *backText;
/** 咨询对象按钮文字 */
@property (nonatomic, copy) NSString *productSendText;

/** SDK事件 */
@property (nonatomic, strong) UdeskSDKActionConfig *actionConfig;
/** SDK风格 */
@property (nonatomic, strong) UdeskSDKStyle *sdkStyle;

@property (nonatomic, strong) NSArray *udViewControllers;

+ (instancetype)customConfig;

- (void)setConfigToDefault;
- (NSString *)quitQueueString;

@end
