//
//  UdeskSDKStyle.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/29.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+UdeskSDK.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKMacro.h"

@interface UdeskSDKStyle : NSObject

/** 用户的消息颜色 */
@property (nonatomic, strong) UIColor  *customerTextColor;
/** 客户的气泡颜色 */
@property (nonatomic, strong) UIColor  *customerBubbleColor;
/** 客户的气泡图片 */
@property (nonatomic, strong) UIImage  *customerBubbleImage;
/** 客户的头像图片 */
@property (nonatomic, strong) UIImage  *customerAvatarImage;
/** 客户的头像URL */
@property (nonatomic, copy  ) NSString *customerAvatarURL;
/** 客户昵称 */
@property (nonatomic, copy  ) NSString *customerNickname;

/** 客服的消息颜色 */
@property (nonatomic, strong) UIColor  *agentTextColor;

/** 客服的气泡颜色 */
@property (nonatomic, strong) UIColor  *agentBubbleColor;

/** 客服的气泡图片 */
@property (nonatomic, strong) UIImage  *agentBubbleImage;

/** 时间颜色（默认灰色）*/
@property (nonatomic, strong) UIColor  *chatTimeColor;

/** IM页面底部输入栏背景颜色(默认白色) */
@property (nonatomic, strong) UIColor  *textViewColor;

/** 消息内容（文字）字体大小 */
@property (nonatomic, strong) UIFont   *messageContentFont;

/** 消息内容（时间）字体大小 */
@property (nonatomic, strong) UIFont   *messageTimeFont;

/** 导航栏返回按钮颜色 */
@property (nonatomic, strong) UIColor  *navBackButtonColor;

/** 导航栏右侧按钮颜色（目前仅特定页面支持，后续版本会完善） */
@property (nonatomic, strong) UIColor  *navRightButtonColor;

/** 导航栏返回按钮图片 */
@property (nonatomic, strong) UIImage  *navBackButtonImage;

/** 导航栏颜色 */
@property (nonatomic, strong) UIColor  *navigationColor;

/** 导航栏背景图片 */
@property (nonatomic, strong) UIImage  *navBarBackgroundImage;

/** 标题颜色 */
@property (nonatomic, strong) UIColor  *titleColor;

/** 标题大小 */
@property (nonatomic, strong) UIFont   *titleFont;

/** 机器人转人工按钮 文案颜色 */
@property (nonatomic, strong) UIColor  *transferButtonColor;

/** 录音颜色 */
@property (nonatomic, strong) UIColor  *recordViewColor;

/** 客户语音时长颜色 */
@property (nonatomic, strong) UIColor  *customerVoiceDurationColor;

/** 客服语音时长颜色 */
@property (nonatomic, strong) UIColor  *agentVoiceDurationColor;

/** 背景颜色 */
@property (nonatomic, strong) UIColor  *tableViewBackGroundColor;

/** 聊天vc背景颜色 (在iPhone x上这个和inputViewColor结合使用) */
@property (nonatomic, strong) UIColor  *chatViewControllerBackGroundColor;

/** 帮助中心搜索文章按钮颜色 */
@property (nonatomic, strong) UIColor  *searchCancleButtonColor;

/** 帮助中心搜索，没有搜索到内容时显示联系我们文字的颜色 */
@property (nonatomic, strong) UIColor  *searchContactUsColor;

/** 帮助中心搜索，没有搜索到内容时显示联系我们边框的颜色 */
@property (nonatomic, strong) UIColor  *contactUsBorderColor;

/** 帮助中心搜索，没有搜索到内容时显示提示内容的颜色 */
@property (nonatomic, strong) UIColor  *promptTextColor;

/** 咨询对象背景颜色 */
@property (nonatomic, strong) UIColor  *productBackGroundColor;

/** 咨询对象标题颜色 */
@property (nonatomic, strong) UIColor  *productTitleColor;

/** 咨询对象子标题颜色 */
@property (nonatomic, strong) UIColor  *productDetailColor;

/** 咨询对象发送按钮背景颜色 */
@property (nonatomic, strong) UIColor  *productSendBackGroundColor;

/** 咨询对象发送按钮颜色 */
@property (nonatomic, strong) UIColor  *productSendTitleColor;

/** 相册导航栏背景颜色 */
@property (nonatomic, strong) UIColor  *albumNavBgColor;
/** 相册标题颜色 */
@property (nonatomic, strong) UIColor  *albumTitleColor;
/** 相册返回按钮颜色 */
@property (nonatomic, strong) UIColor  *albumBackColor;
/** 相册取消按钮颜色 */
@property (nonatomic, strong) UIColor  *albumCancelColor;

/** 超链接点击颜色 */
@property (nonatomic, strong) UIColor *activeLinkColor;
/** 超链接颜色 */
@property (nonatomic, strong) UIColor *linkColor;

/** 客服昵称字号 */
@property (nonatomic, strong) UIFont *agentNicknameFont;
/** 客服昵称颜色 */
@property (nonatomic, strong) UIColor *agentNicknameColor;

/** 商品消息名称字体 */
@property (nonatomic, strong) UIFont *goodsNameFont;
/** 客户商品消息名称颜色 */
@property (nonatomic, strong) UIColor *customerGoodsNameTextColor;
/** 客服商品消息名称颜色 */
@property (nonatomic, strong) UIColor *agentGoodsNameTextColor;
/** 商品消息名称行数 */
@property (nonatomic, assign) NSInteger goodsNameNumberOfLines;

/** wkWebView进度条中未填充部分的颜色（仅支持iOS8以上） */
@property (nonatomic, strong) UIColor *webViewProgressTrackTintColor;
/** wkWebView进度条颜色（仅支持iOS8以上） */
@property (nonatomic, strong) UIColor *webViewProgressTintColor;

+ (instancetype)customStyle;

@end
