//
//  UdeskConfig.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskConfig : NSObject

/*** 用户的消息颜色（默认白色）*/
@property (nonatomic, strong) UIColor  *userTextColor;

/*** 客服的消息颜色（默认黑色）*/
@property (nonatomic, strong) UIColor  *agentTextColor;

/*** 时间颜色（默认灰色）*/
@property (nonatomic, strong) UIColor  *chatTimeColor;

/*** IM页面底部功能栏背景颜色(默认白色) */
@property (nonatomic, strong) UIColor  *inputViewColor;

/*** IM页面底部输入栏背景颜色(默认白色) */
@property (nonatomic, strong) UIColor  *textViewColor;

/*** 消息内容（文字）字体大小 */
@property (nonatomic, assign) float contentFontSize;

/*** 消息内容（时间）字体大小 */
@property (nonatomic, assign) float timeFontSize;

/*** IM页面导航栏返回按钮颜色（默认蓝色）*/
@property (nonatomic, strong) UIColor  *iMBackButtonColor;

/*** IM页面导航栏颜色 */
@property (nonatomic, strong) UIColor  *iMNavigationColor;

/*** IM页面标题颜色 */
@property (nonatomic, strong) UIColor  *iMTitleColor;

/*** 帮助中心导航栏返回按钮用颜色（默认蓝色） */
@property (nonatomic, strong) UIColor  *faqBackButtonColor;

/*** 帮助中心页面导航栏颜色 */
@property (nonatomic, strong) UIColor  *faqNavigationColor;

/*** 文章内容页面导航栏颜色 */
@property (nonatomic, strong) UIColor  *articleContentNavigationColor;

/*** 客户app页面导航栏的颜色 */
@property (nonatomic, strong) UIColor  *oneSelfNavcigtionColor;

/*** 帮助中心标题颜色 */
@property (nonatomic, strong) UIColor  *faqTitleColor;

/*** 文章内容标题颜色 */
@property (nonatomic, strong) UIColor  *articleContentTitleColor;

/*** 文章内容页面返回按钮颜色 */
@property (nonatomic, strong) UIColor  *articleBackButtonColor;

/*** 帮助中心搜索文章按钮颜色 */
@property (nonatomic, strong) UIColor  *searchCancleButtonColor;

/*** 帮助中心搜索，没有搜索到内容时显示联系我们文字的颜色 */
@property (nonatomic, strong) UIColor  *searchContactUsColor;

/*** 帮助中心搜索，没有搜索到内容时显示联系我们边框的颜色 */
@property (nonatomic, strong) UIColor  *contactUsBorderColor;

/*** 帮助中心搜索，没有搜索到内容时显示提示内容的颜色 */
@property (nonatomic, strong) UIColor  *promptTextColor;

/*** 工单页面导航栏返回按钮颜色 */
@property (nonatomic, strong) UIColor  *ticketBackButtonColor;

/*** 工单页面导航栏颜色 */
@property (nonatomic, strong) UIColor  *ticketNavigationColor;

/*** 工单页面标题颜色 */
@property (nonatomic, strong) UIColor  *ticketTitleColor;

/*** 客服状态标题颜色 */
@property (nonatomic, strong) UIColor  *agentStatusTitleColor;

/*** 机器人页面导航栏颜色 */
@property (nonatomic, strong) UIColor  *robotNavigationColor;

/*** 机器人页面导航栏返回按钮颜色 */
@property (nonatomic, strong) UIColor  *robotBackButtonColor;

/*** 机器人页面标题颜色 */
@property (nonatomic, strong) UIColor  *robotTitleColor;

/*** 客服菜单选择器返回按钮颜色 */
@property (nonatomic, strong) UIColor  *agentMenuBackButtonColor;

/*** 客服菜单选择器导航栏颜色 */
@property (nonatomic, strong) UIColor  *agentMenuNavigationColor;

/*** 客服菜单选择器导航栏颜色 */
@property (nonatomic, strong) UIColor  *agentMenuTitleColor;

+ (instancetype)sharedUDConfig;

@end
