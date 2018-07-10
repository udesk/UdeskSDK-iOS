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

typedef enum : NSUInteger {
    UdeskFAQ,
    UdeskTicket
} UdeskType;

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
- (void)pushUdeskInViewController:(UIViewController *)viewController
                       completion:(void (^)(void))completion;

/**
 * 根据后台配置进入UdeskSDK IM相关页面
 * 在一个ViewController中Present出一个客服聊天界面的Modal视图
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)presentUdeskInViewController:(UIViewController *)viewController
                          completion:(void (^)(void))completion;

/**
 进入Udesk 帮助中心/工单 页面

 @param viewController 在一个ViewController中Push出一个客服聊天界面
 @param udeskType 视图类型
 @param completion 完成回调
 */
- (void)pushUdeskInViewController:(UIViewController *)viewController
                        udeskType:(UdeskType)udeskType
                       completion:(void (^)(void))completion;

/**
 进入Udesk 帮助中心/工单 页面
 
 @param viewController 在一个ViewController中Push出一个客服聊天界面
 @param udeskType 视图类型
 @param completion 完成回调
 */
- (void)presentUdeskInViewController:(UIViewController *)viewController
                           udeskType:(UdeskType)udeskType
                          completion:(void (^)(void))completion;

@end
