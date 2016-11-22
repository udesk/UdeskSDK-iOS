//
//  UdeskSDKManager.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskSDKConfig.h"

typedef enum : NSUInteger {
    UdeskFAQ,
    UdeskIM,
    UdeskRobot,
    UdeskMenu,
    UdeskTicket
} UdeskType;

@interface UdeskSDKManager : NSObject

- (instancetype)initWithSDKStyle:(UdeskSDKStyle *)style;

/**
 * 在一个ViewController中Push出一个客服聊天界面
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)pushUdeskViewControllerWithType:(UdeskType)type
                         viewController:(UIViewController *)viewController
                             completion:(void (^)(void))completion;

/**
 * 在一个ViewController中Present出一个客服聊天界面的Modal视图
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)presentUdeskViewControllerWithType:(UdeskType)type
                            viewController:(UIViewController *)viewController
                                completion:(void (^)(void))completion;

/**
 *  设置分配给指定的客服id
 *
 *  @param agentId 客服id
 */
- (void)setScheduledAgentId:(NSString *)agentId;

/**
 *  设置分配给指定的客服组id
 *
 *  @param groupId 客服组id
 */
- (void)setScheduledGroupId:(NSString *)groupId;
/**
 *  设置显示咨询对象消息
 *
 *  @param product 咨询对象
 */
- (void)setProductMessage:(NSDictionary *)product;

/**
 *  通过本地图片设置客户头像
 *
 *  @param avatarImage 客户头像
 */
- (void)setCustomerAvatarWithImage:(UIImage *)avatarImage;

/**
 *  通过URL设置客户头像
 *
 *  @param avatarImage 客户头像URL
 */
- (void)setCustomerAvatarWithURL:(NSString *)avatarURL;
/**
 *  设置IM导航栏标题
 *
 *  @param title IM标题
 */
- (void)setIMNavigationTitle:(NSString *)title;
/**
 *  设置智能机器人导航栏标题
 *
 *  @param title 智能机器人标题
 */
- (void)setRobotNavigationTitle:(NSString *)title;
/**
 *  设置帮助中心导航栏标题
 *
 *  @param title 帮助中心标题
 */
- (void)setFAQNavigationTitle:(NSString *)title;
/**
 *  设置帮助中心导航栏标题
 *
 *  @param title 帮助中心标题
 */
- (void)setTicketNavigationTitle:(NSString *)title;
/**
 *  设置帮助中心文章导航栏标题
 *
 *  @param title 帮助中心标题
 */
- (void)setArticleNavigationTitle:(NSString *)title;
/**
 *  设置帮助中心文章导航栏标题
 *
 *  @param title 帮助中心标题
 */
- (void)setAgentMenuNavigationTitle:(NSString *)title;
/**
 *  设置转人工按钮
 *
 *  @param text 转人工
 */
- (void)setTransferText:(NSString *)text;
/**
 *  设置转人工到客服导航栏菜单
 *
 */
- (void)setTransferToAgentMenu:(BOOL)toMenu;

@end
