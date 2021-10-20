//
//  UdeskSDKManager.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskSDKConfig.h"
#import "UdeskChatViewController.h"
#import "UdeskLocationModel.h"
#import "UdeskGoodsModel.h"
#import "UdeskMessage+UdeskSDK.h"

@interface UdeskSDKManager : NSObject

/**
 * 初始化方法调用
 */
- (instancetype)init;

/**
 * 初始化方法调用
 
 @param sdkStyle Udesk SDK UI风格
 
 */
- (instancetype)initWithSDKStyle:(UdeskSDKStyle *)sdkStyle;

/**
 * 初始化方法调用
 
 @param sdkStyle Udesk SDK UI风格
 @param sdkConfig Udesk SDK配置
 
 */
- (instancetype)initWithSDKStyle:(UdeskSDKStyle *)sdkStyle sdkConfig:(UdeskSDKConfig *)sdkConfig;

/**
 * 初始化方法调用
 
 @param sdkStyle Udesk SDK UI风格
 @param sdkConfig Udesk SDK配置
 @param sdkActionConfig Udesk SDK事件配置
 
 */
- (instancetype)initWithSDKStyle:(UdeskSDKStyle *)sdkStyle sdkConfig:(UdeskSDKConfig *)sdkConfig sdkActionConfig:(UdeskSDKActionConfig *)sdkActionConfig;

/**
 * 根据后台配置进入UdeskSDK IM相关页面
 * 在一个ViewController中Push出一个客服聊天界面
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)pushUdeskInViewController:(UIViewController *)viewController completion:(void (^)(void))completion;

/**
 * 根据后台配置进入UdeskSDK IM相关页面
 * 在一个ViewController中Present出一个客服聊天界面的Modal视图
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)presentUdeskInViewController:(UIViewController *)viewController completion:(void (^)(void))completion;

/**
* present工单留言界面
* 在一个ViewController中Present出一个工单留言界面的Modal视图
* @param viewController 在这个viewController中present工单留言界面
*/
- (void)presentTicketInViewController:(UIViewController *)viewController completion:(void (^)(void))completion;

/**
* 显示帮助中心界面
* 在一个ViewController中Present出一个帮助中心界面的Modal视图
* @param viewController 在这个viewController中present帮助中心界面
* @param animationType 弹出类型，push/present
*/
- (void)showFAQInViewController:(UIViewController *)viewController transiteAnimation:(UDTransiteAnimationType)animationType completion:(void (^)(void))completion;

@end
