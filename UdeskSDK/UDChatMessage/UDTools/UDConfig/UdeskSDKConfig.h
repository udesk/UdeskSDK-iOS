//
//  UdeskSDKConfig.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UdeskSDKStyle.h"

/*
 显示聊天窗口的动画
 */
typedef NS_ENUM(NSUInteger, UDTransiteAnimationType) {
    UDTransiteAnimationTypePresent,
    UDTransiteAnimationTypePush
};

@interface UdeskSDKConfig : NSObject

@property (nonatomic, strong) UdeskSDKStyle *sdkStyle;

/** im标题 */
@property (nonatomic, copy  ) NSString *url;
/** im标题 */
@property (nonatomic, copy  ) NSString *imTitle;

/** 机器人标题 */
@property (nonatomic, copy  ) NSString *robotTtile;

/** 帮助中心标题 */
@property (nonatomic, copy  ) NSString *faqTitle;

/** 帮助中心文章标题 */
@property (nonatomic, copy  ) NSString *articleTitle;

/** 留言提交工单标题 */
@property (nonatomic, copy  ) NSString *ticketTitle;

/** 客服导航栏菜单标题 */
@property (nonatomic, copy  ) NSString *agentMenuTitle;

/** 机器人转人工 */
@property (nonatomic, copy  ) NSString *transferText;

/** 咨询对象发送文字 */
@property (nonatomic, copy  ) NSString *productSendText;

/** 指定客服id */
@property (nonatomic, copy  ) NSString *scheduledAgentId;

/** 指定客服组id */
@property (nonatomic, copy  ) NSString *scheduledGroupId;

/** 是否转人工至客服导航栏菜单（默认直接进会话） */
@property (nonatomic, assign) BOOL     transferToMenu;

/** 客户头像 */
@property (nonatomic, strong) UIImage  *customerImage;

/** 客户头像URL */
@property (nonatomic, copy  ) NSString *customerImageURL;

/** 咨询对象消息 */
@property (nonatomic, strong) NSDictionary *productDictionary;

/** 页面弹出方式 */
@property (nonatomic, assign) UDTransiteAnimationType presentingAnimation;

/** 超链接正则 */
@property (nonatomic, copy, readonly) NSMutableArray *linkRegexs;

+ (instancetype)sharedConfig;

@end
