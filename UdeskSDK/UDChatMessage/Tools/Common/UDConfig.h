//
//  UDConfig.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDConfig : NSObject

/*** 用户的消息颜色（默认白色）*/
@property (nonatomic, copy) UIColor  *userTextColor;

/*** 客服的消息颜色（默认黑色）*/
@property (nonatomic, copy) UIColor  *agentTextColor;

/*** 时间颜色（默认灰色）*/
@property (nonatomic, copy) UIColor  *chatTimeColor;

/*** IM页面底部功能栏背景颜色(默认白色) */
@property (nonatomic, copy) UIColor  *inputViewColor;

/*** IM页面底部输入栏背景颜色(默认白色) */
@property (nonatomic, copy) UIColor  *textViewColor;

/*** 消息内容（文字）字体大小 */
@property (nonatomic, assign) float contentFontSize;

/*** 消息内容（时间）字体大小 */
@property (nonatomic, assign) float timeFontSize;

/*** IM页面导航栏返回按钮颜色（默认蓝色）*/
@property (nonatomic, copy) UIColor  *iMBackButtonColor;

/*** IM页面导航栏颜色 */
@property (nonatomic, copy) UIColor  *iMNavigationColor;

/*** IM页面标题颜色 */
@property (nonatomic, copy) UIColor  *iMTitleColor;

/*** 帮助中心导航栏返回按钮用颜色（默认蓝色） */
@property (nonatomic, copy) UIColor  *faqBackButtonColor;

/*** 帮助中心页面导航栏颜色 */
@property (nonatomic, copy) UIColor  *faqNavigationColor;

/*** 文章内容页面导航栏颜色 */
@property (nonatomic, copy) UIColor  *articleContentNavigationColor;

/*** 客户app页面导航栏的颜色 */
@property (nonatomic, copy) UIColor  *oneSelfNavcigtionColor;

/*** 帮助中心标题颜色 */
@property (nonatomic, copy) UIColor  *faqTitleColor;

/*** 文章内容标题颜色 */
@property (nonatomic, copy) UIColor  *articleContentTitleColor;

/*** 文章内容页面返回按钮颜色 */
@property (nonatomic, copy) UIColor  *articleBackButtonColor;

/*** 帮助中心搜索文章按钮颜色 */
@property (nonatomic, copy) UIColor  *searchCancleButtonColor;

/*** 帮助中心搜索，没有搜索到内容时显示联系我们文字的颜色 */
@property (nonatomic, copy) UIColor  *searchContactUsColor;

/*** 帮助中心搜索，没有搜索到内容时显示联系我们边框的颜色 */
@property (nonatomic, copy) UIColor  *contactUsBorderColor;

/*** 帮助中心搜索，没有搜索到内容时显示提示内容的颜色 */
@property (nonatomic, copy) UIColor  *promptTextColor;

/*** 工单页面导航栏返回按钮颜色 */
@property (nonatomic, copy) UIColor  *ticketBackButtonColor;

/*** 工单页面导航栏颜色 */
@property (nonatomic, copy) UIColor  *ticketNavigationColor;

/*** 工单页面标题颜色 */
@property (nonatomic, copy) UIColor  *ticketTitleColor;

/*** 客服状态标题颜色 */
@property (nonatomic, copy) UIColor  *agentStatusTitleColor;

/*** 机器人页面导航栏颜色 */
@property (nonatomic, copy) UIColor  *robotNavigationColor;

/*** 机器人页面导航栏返回按钮颜色 */
@property (nonatomic, copy) UIColor  *robotBackButtonColor;

/*** 机器人页面标题颜色 */
@property (nonatomic, copy) UIColor  *robotTitleColor;
/**
 *  用户头像
 */
@property (nonatomic, strong) UIImage *headImage;

+ (instancetype)sharedUDConfig;

@end
